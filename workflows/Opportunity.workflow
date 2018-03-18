<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>REVVY__MnCopyOppIDToOppExtId</fullName>
        <description>Copy value of Opp ID field to Opp External Id field</description>
        <field>REVVY__OppExtId__c</field>
        <formula>Id</formula>
        <name>MnCopyOppIDToOppExtId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>REVVY__MnCopyOppNameToOppExtId</fullName>
        <description>Copy value of Opp name field to Opp External Id field</description>
        <field>REVVY__OppExtId__c</field>
        <formula>Name</formula>
        <name>MnCopyOppNameToOppExtId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>REVVY__MnCopyTOppExtId</fullName>
        <actions>
            <name>REVVY__MnCopyOppIDToOppExtId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Copy value of Opp ID to OppExtId at the time of creation of opportunity only.</description>
        <formula>ISBLANK(REVVY__OppExtId__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
