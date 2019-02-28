import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob

import jenkins.plugins.git.GitSCMSource
import jenkins.plugins.git.traits.BranchDiscoveryTrait
import org.jenkinsci.plugins.workflow.libs.GlobalLibraries
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever

import hudson.plugins.git.*;

//Setup shared library
List libraries = [] as ArrayList

jenkins = Jenkins.instance

def scm = new GitSCMSource("https://github.com/Aaquiff/jenkins-shared-lib")
def name = "wso2-jenkins-shared-lib"
def defaultVersion = 'master'

def retriever = new SCMSourceRetriever(scm)
def library = new LibraryConfiguration(name, retriever)
library.defaultVersion = defaultVersion
library.implicit = true
library.allowVersionOverride = true
library.includeInChangesets = true

libraries << library

def global_settings = Jenkins.instance.getExtensionList(GlobalLibraries.class)[0]
global_settings.libraries = libraries
global_settings.save()
println 'Configured Pipeline Global Shared Libraries:\n    ' + global_settings.libraries.collect { it.name }.join('\n    ')

//
// Setup job
//
def repo = "https://github.com/Aaquiff/kubernetes-ei-cd"
def jobName = "wso2-ei"
def jobScm = new GitSCM(repo)
jobScm.branches = [new BranchSpec("*/master")];

def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(jobScm, "Jenkinsfile")

def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, jobName)
job.definition = flowDefinition

parent.save()
parent.reload()