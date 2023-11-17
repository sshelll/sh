#!env bash

# for running everywhere once this dir is in $PATH
source $HOME/sh/utils.sh

# for lsp
source ../utils.sh

function main {
	local groupId=$(must_read_if_empty "groupId(com.example .e.g)" $1)
	local artifactId=$(must_read_if_empty "artifactId(my-java-project .e.g)" $2)
	local archetypeArtifactId=$(read_or_default "archetypeArtifactId(default: maven-archetype-quickstart)" "maven-archetype-quickstart")
	mvn archetype:generate -DgroupId=$groupId -DartifactId=$artifactId -DarchetypeArtifactId=$archetypeArtifactId -DinteractiveMode=false
}

main "$@"
