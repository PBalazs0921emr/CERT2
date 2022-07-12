*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.




Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.PDF
Library    RPA.Tables
Library    DateTime
Library    RPA.Archive
Library    RPA.Desktop
Library             RPA.Dialogs
Library    RPA.Robocorp.Vault
Library    OperatingSystem

*** Variables ***


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${URL}=    Get Secret    CERT2
    Open Website
    ${orders}=    Download The Orders CSV    ${URL}[URL]
    Fill and submit orders    ${orders}
    close the browser
    


*** Keywords ***
Open Website    
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    Yep

Download The Orders CSV
    [Arguments]    ${URL}
    Download    ${URL}
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Fill and submit orders
    [Arguments]    ${orders}
    FOR    ${order}    IN    @{orders} 
        fill order    ${order}
    END

    Create ZIP package from PDF files

fill order
    [Arguments]    ${order}
    Select From List By Index    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath://input[@class="form-control"]    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

    Preview and save picture    ${order}[Order number]

    Wait Until Keyword Succeeds    5x    5s    Submit Order

    ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
    Embed the robot screenshot to the receipt PDF file    ${order}[Order number]

    Click Button    id:order-another
    Click Button    Yep


Submit Order
    Click Button    id:order
    Wait Until Page Contains Element    id:order-completion

Store the receipt as a PDF file
    [Arguments]    ${Order Number}
    Wait Until Element Is Visible    id:order-completion
    ${OrderPdf}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${OrderPdf}    ${OUTPUT_DIR}${/}robots${/}${Order Number}.pdf    

Preview and save picture
    [Arguments]    ${Order Number}
    Click Button    id:preview
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robots${/}${Order Number}.png

Embed the robot screenshot to the receipt PDF file    
    [Arguments]    ${Order Number}
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}robots${/}${Order Number}.png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}robots${/}${Order Number}.pdf     True
    Remove File    ${OUTPUT_DIR}${/}robots${/}${Order Number}.png

close the browser
    Close Browser

Create ZIP package
    ${file_Name}

Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable       ${OUTPUT_DIR}${/}robots/PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}robots${/}
    ...    ${zip_file_name}

    
Collect File Link From User
    Add text input    input    label=CSV
    ${response}=    Run dialog
    RETURN    ${response}