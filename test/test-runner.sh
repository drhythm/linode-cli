#!/bin/bash

# Trap ctrl-c and reset .env file
trap ctrl_c INT

function ctrl_c() {
    source ./.env

    unset LINODE_CLI_TOKEN

    echo "export TOKEN_1=$TOKEN_1" > ./.env
    echo "export TOKEN_2=$TOKEN_2" >> ./.env
    echo "export TOKEN_1_IN_USE_BY=NONE" >> ./.env
    echo "export TOKEN_2_IN_USE_BY=NONE" >> ./.env
}

if [[ $1 = "--allow-delete-resources" ]]; then
    echo -e "\n\n"
    read -p "WARNING: Running the Linode CLI tests will REMOVE ALL account data. Are you sure? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
    	echo "Phew, that was a close one!"
        exit 0
    fi

    testsWorkingDir=$(echo $PWD | grep test)

    if [[ $? != 0 ]]
    then
        cd $PWD/test
    fi

    find . -name *.bats -not \( -path './test_helper*' \) | parallel --jobs 2 bats
elif [[ $1 = "--force" ]]; then

    testsWorkingDir=$(echo $PWD | grep test)

    if [[ $? != 0 ]]
    then
        cd $PWD/test
    fi

    find . -name *.bats -not \( -path './test_helper*' \) | parallel --jobs 2 bats
else
    echo -e "\n ####WARNING!#### \n"
    echo -e  "Running the Linode CLI tests requires removing all resources on your account\n"
    echo -e "Run this command with the --allow-delete-resources flag to accept this fate\n"
    exit 1
fi
