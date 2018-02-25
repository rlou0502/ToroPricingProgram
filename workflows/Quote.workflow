<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Final_Approval_of_Deviation_Complete</fullName>
        <ccEmails>deb.schwarze@toro.com</ccEmails>
        <ccEmails>bryan.isle@toro.com</ccEmails>
        <description>Final Approval of Deviation Complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Intl_Email_Templates/INT_SWS_Sales_Price_Change_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>SWS_ARA_Show_Update_Quote_Name</fullName>
        <description>Updates quote name to Account Name + &lt;ARA SHOW YEAR&gt; + ARA Show when quote is created using SWS ARA Quote record type.</description>
        <field>Name</field>
        <formula>Opportunity.Account.Name  + &quot; - &quot; + $Setup.ToroSettings__c.SWS_ARA_Show_Year__c + &quot; ARA Show Quote&quot;</formula>
        <name>SWS ARA Show Update Quote Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Status</fullName>
        <description>Update Status Field on Quote for reporting purposes</description>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Update Quote Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Status_when_Rejected</fullName>
        <field>Status</field>
        <literalValue>Denied</literalValue>
        <name>Update Quote Status when Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Status_when_Submitted</fullName>
        <description>Update Quote Status to In Review once submitted to help with reporting.</description>
        <field>Status</field>
        <literalValue>In Review</literalValue>
        <name>Update Quote Status when Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SWS_ARA_Show_Quote_Expiration_Dat</fullName>
        <field>ExpirationDate</field>
        <formula>DATE(VALUE($Setup.ToroSettings__c.SWS_ARA_Show_Year__c),03,31)</formula>
        <name>Update SWS ARA Show Quote Expiration Dat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SWS ARA Show Default Quote Expiration Date</fullName>
        <actions>
            <name>Update_SWS_ARA_Show_Quote_Expiration_Dat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.RecordTypeId</field>
            <operation>equals</operation>
            <value>SWS ARA Show</value>
        </criteriaItems>
        <description>Defaults Quote Expiration Date to Today+30</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SWS ARA Show Default Quote Name</fullName>
        <actions>
            <name>SWS_ARA_Show_Update_Quote_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.RecordTypeId</field>
            <operation>equals</operation>
            <value>SWS ARA Show</value>
        </criteriaItems>
        <description>Defaults Quote Name to Account Name + &lt;Show Year&gt; ARA Show</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
