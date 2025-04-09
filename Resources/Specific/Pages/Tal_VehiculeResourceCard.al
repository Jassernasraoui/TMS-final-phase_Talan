page 50126 "Vehicule resources card "
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = Resource;
    Caption = 'Vehicule details and verification';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    // Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a description of the resource.';
                }
                field(" License plate No."; rec." License plate No.")
                {
                    Caption = ' Specifies the vehicles registration number';
                    ApplicationArea = all;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = Jobs;
                    Importance = Additional;
                    ToolTip = 'Specifies information in addition to the description.';
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Jobs;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the resource is a person or a machine.';
                    Editable = false;
                    trigger OnValidate()
                    begin
                        if Rec.Type = rec.type::Person then
                            Rec.Validate(Type, rec.Type::Machine);
                    end;

                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
                }
                field("Resource Group No."; Rec."Resource Group No.")
                {
                    ApplicationArea = Jobs;
                    Importance = Promoted;
                    ToolTip = 'Specifies the resource group that this resource is assigned to.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                }
            }
            group("Driver Identification")
            {


            }
            group("Capacity")
            {
                field("Max Capacity Charge "; rec."Max Capacity Charge")
                {
                    Caption = ' Specifies the maximum load capacity of the vehicle in kilograms';
                    ApplicationArea = all;
                }
                field("Current kilometres"; rec."Current kilometres")
                {
                    Caption = 'Indicates the total distance traveled by the vehicle ';
                    ApplicationArea = all;
                }

                field("Last Maintenance Date"; rec."Last Maintenance Date")
                {
                    Caption = 'Dernière Maintenance';
                    ApplicationArea = all;
                }
                field("Next Maintenance Date"; rec."Next Maintenance Date")
                {
                    Caption = 'Prochaine Maintenance';
                    ApplicationArea = all;
                }
            }
            group("Size")

            {
                field("Vehicle Height"; rec."Vehicle Height")
                {
                    ApplicationArea = all;
                    Caption = 'Hauteur du véhicule (en mètres)';
                }

                field("Vehicle Width"; rec."Vehicle Width")
                {
                    ApplicationArea = all;
                    Caption = 'Largeur du véhicule (en mètres)';
                }

                field("Vehicle Length"; rec."Vehicle Length")
                {
                    ApplicationArea = all;
                    Caption = 'Longueur du véhicule (en mètres)';
                }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the cost of one unit of the selected item or resource.';
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the percentage of the item''s last purchase cost that includes indirect costs, such as freight that is associated with the purchase of the item.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                }
                field("Price/Profit Calculation"; Rec."Price/Profit Calculation")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the relationship between the Unit Cost, Unit Price, and Profit Percentage fields associated with this resource.';
                }
                field("Profit %"; Rec."Profit %")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the profit margin that you want to sell the resource at. You can enter a profit percentage manually or have it entered according to the Price/Profit Calculation field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Jobs;
                    Importance = Promoted;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Default Deferral Template Code"; Rec."Default Deferral Template Code")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Default Deferral Template';
                    ToolTip = 'Specifies the default template that governs how to defer revenues and expenses to the periods when they occurred.';
                }
                field("Automatic Ext. Texts"; Rec."Automatic Ext. Texts")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies that an Extended Text Header will be added on sales or purchase documents for this resource.';
                }
                field("IC Partner Purch. G/L Acc. No."; Rec."IC Partner Purch. G/L Acc. No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the intercompany g/l account number in your partner''s company that the amount for this resource is posted to.';
                }
            }



        }
    }
}
