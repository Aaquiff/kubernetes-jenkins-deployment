FILE=$1

echo "# WSO2 CI/CD Setup Provider" > $FILE

cat >> $FILE << "EOF"

WSO2_USERNAME=$1
WSO2_PASSWORD=$2
REGISTRY_USERNAME=$3
REGISTRY_PASSWORD=$4
REGISTRY_EMAIL=$5
JENKINS_USERNAME=$6
JENKINS_PASSWORD=$7

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

cd jenkins

replaceTag() {
    sed -i '' "s|$1|$2|" values.yaml
}

replaceTag "<WSO2_USERNAME>" "$WSO2_USERNAME"
replaceTag "<WSO2_PASSWORD>" "$WSO2_PASSWORD"
replaceTag "<REGISTRY_USERNAME>" "$REGISTRY_USERNAME"
replaceTag "<REGISTRY_PASSWORD>" "$REGISTRY_PASSWORD"
replaceTag "<REGISTRY_EMAIL>" "$REGISTRY_EMAIL"
replaceTag "<JENKINS_USERNAME>" "$JENKINS_USERNAME"
replaceTag "<JENKINS_PASSWORD>" "$JENKINS_PASSWORD"

helm dependency build
helm dependency update

# helm upgrade jenkins . -f values.yaml --install --namespace jenkins

EOF
