*** Settings ***

Resource        tests/NPSP.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Variables ***
${level_name}
${contact_id}

*** Test Cases ***

Create Level and Verify Fields
    ${level_id}  ${level_name}     Create Level
    Set Global Variable      ${level_name}
    Go To Record Home         ${level_id}
    Confirm Value    Minimum Amount (>=)    0.10    Y
    Confirm Value    Maximum Amount (<)     0.90    Y

Edit Level and Verify Fields
    # --------------------------------
    # Modify the Level Values and validate that they save correctly
    # --------------------------------
    Click Link    link=Show more actions
    Click Link    link=Edit
    Select Frame With Title    Levels
    Enter Level Dd Values    Source Field    Smallest Gift
    Enter Level Values
    ...            Minimum Amount=0.01
    ...            Maximum Amount=0.99
    Set Focus To Element   xpath: //input[@value='Save']
    Click Button  Save
    Unselect Frame
    Wait For Locator  breadcrumb  Level
    Reload Page
    Wait Until Loading Is Complete
    Confirm Value    Minimum Amount (>=)    0.01    Y
    Confirm Value    Maximum Amount (<)     0.99    Y
    Confirm Value    Source Field    npo02__SmallestAmount__c    Y

Validate Level Assignment in Batch Job
    # --------------------------------
    # Modify the SmallestGift field to allow the level to be applied
    # --------------------------------
    &{contact} =  API Create Contact
    Set Global Variable     ${contact_id}       &{contact}[Id]
    Go To Record Home       ${contact_id}
    Select Tab              Details
    # Scroll down to the section below 'Donation Information' so the 'Smallest Gift' field is visible
    Scroll Element Into View    xpath: //span[text()='Donation Totals']
    Click Edit Button    Edit Smallest Gift
    Populate Form
    ...                    Smallest Gift=0.75
    Click Record Button    Save
    Wait Until Loading Is Complete
    Scroll Element Into View    xpath: //span[text()='Donation Totals']
    Confirm Value    Smallest Gift    0.75    Y
    # --------------------------------
    # Open NPSP Settings and run the Levels batch job
    # --------------------------------
    Open NPSP Settings      Bulk Data Processes         Level Assignment Batch
    Click Element           //input[contains(@class, 'stg-run-level-batch')]
    Wait for Locator        npsp_settings.completed
    # --------------------------------
    # Return to the Contact to validate the updated Level field
    # --------------------------------
    Go To Record Home       ${contact_id}
    Select Tab    Details
    Verify Field Value    Level    ${level_name}    Y
    # --------------------------------
    # Modify the SmallestGift field to change the applied level
    # --------------------------------
    Scroll Element Into View    xpath: //span[text()='Donation Totals']
    Click Edit Button    Edit Smallest Gift
    Populate Form
    ...                    Smallest Gift=2.0
    Click Record Button    Save
    Wait Until Loading Is Complete
    # --------------------------------
    # Open NPSP Settings and run the Levels batch job
    # --------------------------------
    Open NPSP Settings      Bulk Data Processes         Level Assignment Batch
    Click Element           //input[contains(@class, 'stg-run-level-batch')]
    Wait for Locator        npsp_settings.completed
    # --------------------------------
    # Return to the Contact to validate the updated Level field
    # --------------------------------
    Go To Record Home       ${contact_id}
    Select Tab    Details
    Confirm Value    Level             ${level_name}    N
    Verify Field Value    Previous Level    ${level_name}    Y

Delete Level and Validate Contact
    # --------------------------------
    # Delete the Level and validate that it was removed from the Contact
    # --------------------------------
    Click Link    link=${level_name}
    Click Link    link=Show more actions
    Click Link    link=Delete
    Click Modal Button    Delete
    Go To Record Home       ${contact_id}
    Select Tab    Details
    Confirm Value    Level    ${level_name}    N
