<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Percent_Container_Fill_Rollup</fullName>
        <field>Percent_Container_Rollup__c</field>
        <formula>Percent_of_Container__c</formula>
        <name>Percent Container Fill Rollup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Standard_Cost_for_Quote_Roll_up</fullName>
        <description>Update that puts a value into the &quot;Standard Cost for Roll up&quot; field so it can be moved up into Quotes for use in the Deviation Process.</description>
        <field>Std_Cost_for_Rollup__c</field>
        <formula>Standard_Cost__c</formula>
        <name>Populate Standard Cost for Quote Roll up</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DNET_Value</fullName>
        <description>Provides DNET Value for rollup for International Quotes and Deviations.</description>
        <field>DNET_Value__c</field>
        <formula>Line_Quantity__c * PricebookEntry.UnitPrice</formula>
        <name>Update DNET Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Line_Item_Points</fullName>
        <field>Point_Value__c</field>
        <formula>Product2.Point_Value__c</formula>
        <name>Update Quote Line Item Points</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Product ID to Product ID 2</fullName>
        <active>false</active>
        <description>Sets Product ID 2 to match Product ID for modeling work</description>
        <formula>NOT(ISBLANK(Product2Id)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update DNET Value</fullName>
        <actions>
            <name>Update_DNET_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Provides a DNET Value for a line item on a quote available for rollup and calucations for International Deviations.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Percent Container Rollup for roll-up field at the Quote level%2E</fullName>
        <actions>
            <name>Percent_Container_Fill_Rollup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Percent_of_Container__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.RecordTypeId</field>
            <operation>equals</operation>
            <value>INT Quote</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Points</fullName>
        <actions>
            <name>Update_Quote_Line_Item_Points</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Product2.Point_Value__c)), OR(Quote.Pricebook2.Name=&quot;Pricebook_SWS&quot;+$Setup.ToroSettings__c.SWS_ARA_Show_Year__c+&quot;COOPUSD&quot;, Quote.Pricebook2.Name=&quot;Pricebook_SWS&quot;+$Setup.ToroSettings__c.SWS_ARA_Show_Year__c+&quot;STDCAD&quot;, Quote.Pricebook2.Name=&quot;Pricebook_SWS&quot;+$Setup.ToroSettings__c.SWS_ARA_Show_Year__c+&quot;STDUSD&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Standard Cost Roll Up</fullName>
        <actions>
            <name>Populate_Standard_Cost_for_Quote_Roll_up</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Standard_Cost__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.RecordTypeId</field>
            <operation>equals</operation>
            <value>INT Quote</value>
        </criteriaItems>
        <description>Update Standard_Cost_Rollup__c to reflect standard cost of products pulled into quotes for the purpose of having all standard costs associated to quoted items totalled for deviation analysis.  Used by International.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
