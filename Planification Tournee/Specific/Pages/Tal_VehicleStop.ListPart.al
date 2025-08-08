page 73501 "Vehicle Stop List"
{
    PageType = ListPart;
    SourceTable = "vehicle Stop Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; rec."type")
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                    ToolTip = 'Specifies the type of document associated with this vehicle stop.';
                    Editable = false;
                }
                field("Stop No."; rec."Stop No.")
                {
                    Caption = ' Line No';
                }
                field("Customer No."; rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer/Vendor No.';
                    ToolTip = 'Specifies the account number.';
                    Editable = false;
                    Style = Strong;
                }
                field("item"; rec."item")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the item number associated with the delivery.';
                    Editable = false;
                }
                field("Description"; rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the delivery.';
                    Editable = false;
                }
                field("Delivery Address"; rec."Delivery Address") { }
                field("Estimated Arrival Time"; rec."Estimated Arrival Time") { Visible = false; }
                field("Estimated Departure Time"; rec."Estimated Departure Time") { Visible = false; }
                field("Quantity per Location"; CompanyLocationInventory)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity in Company Location';
                    ToolTip = 'Shows available inventory at the company\s location.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        AdjustInventory: Page "Adjust Inventory";
                    begin
                        if Rec."Item" <> '' then begin
                            AdjustInventory.SetItem(Rec."Item");
                            AdjustInventory.RunModal();
                            // Refresh the display after adjustment
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field("Quantity to deliver"; rec."Quantity to deliver")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the quantity that needs to be prepared for delivery.';
                    Editable = false;
                    style = StandardAccent;
                }
                field("Quantity to Prepare"; rec."Quantity to prepare")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity to Prepare';
                    ToolTip = 'Specifies the quantity that needs to be prepared for delivery.';
                    Editable = QuantityToPrepareEditable;
                    ShowMandatory = true;

                    style = StandardAccent;
                }
                field("Quantity Prepared"; rec."Quantity prepared")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Prepared';
                    ToolTip = 'Specifies the quantity that has been prepared for delivery.';
                    style = StandardAccent;
                    ShowMandatory = true;

                }
                field("Gross weight"; rec."Gross weight")
                {
                    ApplicationArea = All;
                    Caption = 'Gross Weight';
                    ToolTip = 'Specifies the gross weight of the delivery.';
                }
                field("unit volume"; rec."Unit volume")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Volume';
                    ToolTip = 'Specifies the unit volume of the delivery.';
                }
            }
        }

    }
    var
        CompanyLocationInventory: Decimal;
        CompanyLocationCode: Code[20];
        QuantityToPrepareEditable: Boolean;

    trigger OnOpenPage()
    var
        TripSetup: Record "Trip Setup";
    begin
        // Get company location code from setup
        if TripSetup.Get() then
            CompanyLocationCode := TripSetup."Location Code";
    end;

    trigger OnAfterGetRecord()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        CompanyLocationInventory := 0;
        if (Rec."Item" <> '') and (CompanyLocationCode <> '') then begin
            ItemLedgerEntry.SetCurrentKey("Item No.");
            ItemLedgerEntry.SetRange("Item No.", Rec."Item");
            ItemLedgerEntry.SetRange("Location Code", CompanyLocationCode);
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.CalcSums("Remaining Quantity");
            CompanyLocationInventory := ItemLedgerEntry."Remaining Quantity";
        end;

        // Set editability of Quantity to Prepare based on document type
        QuantityToPrepareEditable := Rec.Type <> Rec.Type::Purchase;
    end;
}
