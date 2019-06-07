FILE=$1
cat > $FILE << "EOF"
#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2017 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

set -e 

ECHO=`which echo`
READ=`which read`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

echoBold "WSO2 CI/CD Setup Provider"

EOF

for entry in `find jenkins ! -name '.*'`; do
    if test -f $entry; then
        filecontent=`cat $entry`
        echo "cat > $entry << \"EOF\"" >> $FILE
        echo "$filecontent" >> $FILE
        echo "EOF" >> $FILE
        echo "" >> $FILE
    else
        echo "mkdir $entry" >> $FILE
        echo "" >> $FILE
    fi
done

cat >> $FILE << "EOF"
cat > app.yaml << "EOF"
applications:
  - name: APP_NAME
    email: EMAIL
    testScript:
      path: TEST_PATH
      command: TEST_COMMAND
    chart:
      name: CHART_NAME
      repo: 'CHART_REPO'
    images:
      - wso2Image: 'WSO2_IMAGE'
        organization: ORGANIZATION
        repository: REPOSITORY
        gitRepo: 'GIT_REPO'
EOF

echo "EOF" >> $FILE

cat >> $FILE << "EOF"

replaceTag() {
    sed -i '' "s|$1|$2|" jenkins/values.yaml
}

if [ $1 != "" ]; then
  replaceTag "<WSO2_SUBSCRIPTION_USERNAME>" $1
  replaceTag "<WSO2_SUBSCRIPTION_PASSWORD>" $2
  replaceTag "<REGISTRY_USERNAME>" $3
  replaceTag "<REGISTRY_PASSWORD>" $4
  replaceTag "<REGISTRY_EMAIL>" $5
  replaceTag "<JENKINS_USERNAME>" $6
  replaceTag "<JENKINS_PASSWORD>" $7
  replaceTag "<GITHUB_USERNAME>" $8
  replaceTag "<GITHUB_PASSWORD>" $9
else
  ${READ} -p "Enter Your WSO2 Username: " WSO2_SUBSCRIPTION_USERNAME
  ${READ} -s -p "Enter Your WSO2 Password: " WSO2_SUBSCRIPTION_PASSWORD
  ${ECHO}
  ${READ} -p "Enter Your Registry Username: " REGISTRY_USERNAME
  ${READ} -s -p "Enter Your Registry Password: " REGISTRY_PASSWORD
  ${ECHO}
  ${READ} -p "Enter Your Reigstry Email: " REGISTRY_EMAIL
  ${READ} -p "Enter Your Jenkins username: " JENKINS_USERNAME
  ${READ} -s -p "Enter Your Jenkins password: " JENKINS_PASSWORD
  ${ECHO}

  ${READ} -p "Enter Your Github username: " GITHUB_USERNAME
  ${READ} -s -p "Enter Your Github password: " GITHUB_PASSWORD
  ${ECHO}

  replaceTag "<WSO2_SUBSCRIPTION_USERNAME>" "$WSO2_SUBSCRIPTION_USERNAME"
  replaceTag "<WSO2_SUBSCRIPTION_PASSWORD>" "$WSO2_SUBSCRIPTION_PASSWORD"
  replaceTag "<REGISTRY_USERNAME>" "$REGISTRY_USERNAME"
  replaceTag "<REGISTRY_PASSWORD>" "$REGISTRY_PASSWORD"
  replaceTag "<REGISTRY_EMAIL>" "$REGISTRY_EMAIL"
  replaceTag "<JENKINS_USERNAME>" "$JENKINS_USERNAME"
  replaceTag "<JENKINS_PASSWORD>" "$JENKINS_PASSWORD"
  replaceTag "<GITHUB_USERNAME>" "$GITHUB_USERNAME"
  replaceTag "<GITHUB_PASSWORD>" "$GITHUB_PASSWORD"
fi

${READ} -p "Do you want to add an application? " -n 1 -r
${ECHO}

if [[ ${REPLY} =~ ^[Yy]$ ]]; then

  ${READ} -p "Name: " APP_NAME

  ${READ} -p "Path to the test script: " TEST_PATH
  ${READ} -p "Test command: " TEST_COMMAND

  ${READ} -p "Chart name: " CHART_NAME
  ${READ} -p "Url of git repo containin the chart" CHART_REPO

  ${READ} -p "WSO2 image: " WSO2_IMAGE
  ${READ} -p "Docker organization: " ORGANIZATION
  ${READ} -p "Docker repository: " REPOSITORY
  ${READ} -p "Git repository containing the docker resources: " GIT_REPO

  function replaceValues() {
      sed "s|$1|$2|"
  }

  echo "" >> jenkins/values.yaml
  cat app.yaml | 
  replaceValues APP_NAME $APP_NAME |
  replaceValues TEST_PATH $TEST_PATH |
  replaceValues TEST_COMMAND $TEST_COMMAND |
  replaceValues CHART_NAME $CHART_NAME |
  replaceValues CHART_REPO $CHART_REPO |
  replaceValues CHART_REPO $WSO2_IMAGE |
  replaceValues CHART_REPO $ORGANIZATION |
  replaceValues CHART_REPO $REPOSITORY |
  replaceValues CHART_REPO $GIT_REPO |
  replaceValues EMAIL $WSO2_SUBSCRIPTION_USERNAME >> jenkins/values.yaml

fi

cd jenkins
helm dependency build
# helm dependency update

EOF
