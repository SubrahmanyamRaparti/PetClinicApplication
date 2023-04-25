#!/bin/bash

DIR="./application/"
REGION="ap-south-1"

# Make sure to execute this script from project ROOT directory.
if [ -d $DIR ];
then 
    echo 'ALL GOOD. Trying to copy files to AWS Code Commit.'
    cd .. && echo $PWD
    git clone ssh://git-codecommit.$REGION.amazonaws.com/v1/repos/pet-clinic-application
    
    # Copy application code present in GITHUB repo AWS codecommit repo directory.
    cp -r ./pet-clinic-application-iac/application/* pet-clinic-application
    
    cd pet-clinic-application
    git add . && git commit -m "Cloned source code from GITHUB to AWS codecommit. ONE TIME SETUP !!"
    
    git push origin master
else
    echo "ERROR! Please run the script project from root directory."
    exit 1
fi;
