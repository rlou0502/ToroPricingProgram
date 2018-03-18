<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>REVVY__MnCopyAcctIDToAcctExtId</fullName>
        <description>Copy value of Acct ID field to Acct External Id field</description>
        <field>REVVY__AcctExtId__c</field>
        <formula>Id</formula>
        <name>MnCopyAcctIDToAcctExtId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>REVVY__MnCopyAcctNameToAcctExtId</fullName>
        <description>Copy value of Acct name field to Acct External Id field</description>
        <field>REVVY__AcctExtId__c</field>
        <formula>Name</formula>
        <name>MnCopyAcctNameToAcctExtId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>REVVY__MnCopyToAcctExtId</fullName>
        <actions>
            <name>REVVY__MnCopyAcctIDToAcctExtId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Copy value of Acct ID to AcctExtId at the time of creation of account only.</description>
        <formula>ISBLANK(REVVY__AcctExtId__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
