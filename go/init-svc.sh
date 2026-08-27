#!/usr/bin/env bash

# Initialize a go backend project skeleton in the CURRENT directory.
#
# Layout:
#   cmd/app/main.go
#   internal/{config,dal,facade,handler,model,server,service}/init.go
#   internal/model/{requests,responses}
#   configs/  scripts/
#   Makefile  Dockerfile
#
# Usage:
#   cd <project-root> && init-repo.sh [mod-name]
#
# The current directory must be empty (an existing .git is allowed).

# for running everywhere once this dir is in $PATH
source $HOME/sh/utils.sh
source $HOME/sh/logger.sh

set -euo pipefail

# write file only if absent, $1: path, stdin: content
function write_file {
    local path=$1
    if [[ -f $path ]]; then
        log_warn "skip existing $path"
        cat >/dev/null
        return
    fi
    cat >"$path"
    log_success "created $path"
}

# abort unless CWD is empty, .git is tolerated (freshly cloned empty repo)
function ensure_dir_empty {
    local entry
    for entry in * .*; do
        [[ $entry == "." || $entry == ".." || $entry == ".git" ]] && continue
        # unmatched globs come back literally when nothing matches
        [[ -e $entry || -L $entry ]] || continue
        log_error "$PWD is not empty (found: $entry), refuse to init"
        exit 1
    done
}

function init_mod {
    local mod_name=$1

    if [[ -f go.mod ]]; then
        log_warn "go.mod already exists, skip go mod init"
        return
    fi

    go mod init "$mod_name"
    log_success "go mod init $mod_name"
}

function make_dirs {
    mkdir -p cmd/app
    mkdir -p internal/{config,dal,facade,handler,model,server,service}
    mkdir -p internal/model/{requests,responses}
    mkdir -p configs
    mkdir -p scripts
    log_success "directories created"
}

function gen_go_files {
    write_file cmd/app/main.go <<-'EOF'
		package main

		func main() {
		}
	EOF

    local pkg
    for pkg in config dal facade handler server service; do
        write_file "internal/$pkg/init.go" <<-EOF
			package $pkg

			import "sync"

			var initOnce = sync.Once{}

			func Init() {
				initOnce.Do(func() {
				})
			}
		EOF
    done

    write_file internal/model/init.go <<-'EOF'
		package model
	EOF

    write_file internal/model/requests/requests.go <<-'EOF'
		package requests
	EOF

    write_file internal/model/responses/responses.go <<-'EOF'
		package responses
	EOF
}

function gen_makefile {
    # NOTE: recipe lines must be real tabs, so no <<- here
    write_file Makefile <<'EOF'
.PHONY: cloc

cloc:
	@which cloc >/dev/null 2>&1 && \
	cloc . --exclude-dir=target,.git,.github,vendor || \
	echo "cloc is not installed, skipping..."
EOF
}

function gen_dockerfile {
    local service_name=$1
    local go_version=$(go env GOVERSION 2>/dev/null | sed 's/^go//')
    go_version=$(unwrap_or_default "$go_version" "1.24.2")

    write_file Dockerfile <<-EOF
		# syntax=docker/dockerfile:1

		ARG GO_VERSION=$go_version
		ARG BIN_NAME=$service_name
		ARG MAIN_PATH=cmd/app/main.go

		################################################################################
		# Create a stage for building the application.
		FROM --platform=\$BUILDPLATFORM golang:\${GO_VERSION} AS build

		ARG BIN_NAME
		ARG MAIN_PATH

		WORKDIR /app

		# Download dependencies as a separate step to take advantage of Docker's caching.
		RUN --mount=type=cache,target=/go/pkg/mod/ \\
		    --mount=type=bind,source=go.sum,target=go.sum \\
		    --mount=type=bind,source=go.mod,target=go.mod \\
		    go mod download -x

		# This is the architecture you're building for, which is passed in by the builder.
		ARG TARGETARCH

		RUN --mount=type=cache,target=/go/pkg/mod/ \\
		    --mount=type=bind,target=. \\
		    CGO_ENABLED=0 GOARCH=\$TARGETARCH go build -o /bin/\$BIN_NAME ./\$MAIN_PATH

		################################################################################
		# Create a new stage for running the application.
		FROM alpine:latest AS final

		ARG BIN_NAME
		ENV BIN_NAME=\${BIN_NAME}

		WORKDIR /app

		RUN --mount=type=cache,target=/var/cache/apk \\
		    apk --update add \\
		    ca-certificates \\
		    tzdata \\
		    && \\
		    update-ca-certificates

		# Create a non-privileged user that the app will run under.
		ARG UID=10001
		RUN adduser \\
		    --disabled-password \\
		    --gecos "" \\
		    --home "/nonexistent" \\
		    --shell "/sbin/nologin" \\
		    --no-create-home \\
		    --uid "\${UID}" \\
		    appuser

		COPY --from=build /bin/\$BIN_NAME /bin/
		COPY ./scripts/ scripts/
		COPY ./configs/ configs/

		RUN chown -R appuser:appuser /app

		USER appuser

		# Expose the port that the application listens on.
		EXPOSE 8080

		ENTRYPOINT [ "/bin/$service_name" ]
	EOF
}

function main {
    if ! check_command_exists "go"; then
        log_error "go not found in \$PATH"
        exit 1
    fi

    local service_name=$(basename "$PWD")

    yellow_fg "Init go mod?"
    if confirm_v; then
        local mod_name=${1:-}
        if [[ -z $mod_name ]]; then
            mod_name=$(read_or_default "mod name (default: $service_name)" "$service_name")
        fi
        log_info "init repo in $PWD (service: $service_name, mod: $mod_name)"
        init_mod "$mod_name"
    fi

    ensure_dir_empty

    make_dirs
    gen_go_files
    gen_makefile
    gen_dockerfile "$service_name"

    gofmt -w ./cmd ./internal
    go build ./... >/dev/null

    log_success "done"
}

main "$@"
