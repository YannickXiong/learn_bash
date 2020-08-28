SOLC_HOME="/usr/local/Cellar/solidity"
solcVersion=""
curentVersion=""

function getCurrentVersion(){
    currentVersion=`solc --version|grep Version |cut -d " " -f 2 |cut -d "+" -f1`
}

function switch(){
    if [[ -f ${solc} ]]; then
        getCurrentVersion
	    beforeVersion=${currentVersion}

        cd /usr/local/bin
        rm -rf solc
        ln -s ${solc} solc

        getCurrentVersion
        afterVersion=${currentVersion}

        if [[ "x"${afterVersion} == "x"${solcVersion} ]]; then
            echo "swit solc from version-${beforeVersion} to version-${afterVersion} successfully."
        else
            echo 
        fi    
    else
        echo "solc does not exist in path: ${solc}"
        echo "nothing to do."
    fi
}

if [[ $# -lt 1 ]];then
    echo "expected one parameter, while 0 given."
    echo "usage: $0 <solc-version>"
    echo 'eg: $0 "0.4.25"'
else
    solcVersion=$1
    solc=${SOLC_HOME}/${solcVersion}/bin/solc

    switch
fi


