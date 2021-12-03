*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           Collections
Library           RPA.Dialogs
Library           OperatingSystem
Library           RPA.RobotLogListener
Library           RPA.Robocorp.Vault

*** Keywords ***
Get url from user
    Add text input  message    label=Please provide the url of your order list:    placeholder=https://yourorderlisting.com/thanks.csv
    ${input}=    Run dialog
    [Return]    ${input}
Open the website
    ${secretdata}=    Get Secret    robocorp
    ${browserdata}    Set Variable    ${secretdata}[url]
    Log    ${browserdata}
    Open Available Browser    ${browserdata}
    #Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Close pop up
Close pop up   
    Click Button    OK
Download order file
    ${url}=    Get url from user
    #Download    https://robotsparebinindustries.com/orders.csv   overwrite=True
    Download    ${url.message}   overwrite=True
Make orders from csv file
    Create Directory  ${CURDIR}${/}output${/}receipts
     ${orders}=    Read table from CSV    orders.csv    header=True
     FOR    ${order}    IN    @{orders}
        Fill the form    ${order}
        Wait Until Element Is Visible    id:receipt
        ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${receipt_html}    ${CURDIR}${/}output${/}receipts${/}${order}[Order number].pdf
        Screenshot  //div[@id="robot-preview-image"]  ${CURDIR}${/}output${/}receipts${/}${order}[Order number].png
        Add Watermark Image To Pdf  ${CURDIR}${/}output${/}receipts${/}${order}[Order number].png  ${CURDIR}${/}output${/}receipts${/}${order}[Order number].pdf  ${CURDIR}${/}output${/}receipts${/}${order}[Order number].pdf 
        Click Button When Visible    order-another
        Close pop up
    END

Submit order
    Click Button    order
    Assert ordered  
Assert ordered
    Page Should Contain Element    receipt
Fill the form   
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]

    ${partnum_body}=    Convert To String    ${order}[Body]
    Log Many    ${partnum_body}
    ${id_partnum}=    Set Variable    id-body-${partnum_body}
    Click Button    id:${id_partnum}

    Set Local Variable      ${input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Input Text    ${input_legs}    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    preview
    Wait Until Element Is Visible   robot-preview-image
    Wait Until Keyword Succeeds    5x    0.5 sec    Submit order
    Page Should Contain Element    receipt

Create zip archive
    Archive Folder With Zip  ${CURDIR}${/}output${/}receipts  ${OUTPUT_DIR}${/}receipts.zip

*** Tasks ***
Order robot and save reciept and image in zip file
    Open the website
    Download order file
    Make orders from csv file
    Create zip archive