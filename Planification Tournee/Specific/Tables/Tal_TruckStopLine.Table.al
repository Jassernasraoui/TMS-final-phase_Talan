table 73607 "vehicle Stop Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "Fiche No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(77002; "Stop No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(77003; "Customer No."; Code[100])
        {
            DataClassification = CustomerContent;
        }
        field(77004; "Delivery Address"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(77005; "Estimated Arrival Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(77006; "Estimated Departure Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(77007; "Quantity to deliver"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(77008; "Remarks"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(77009; "Gross weight"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(77010; "Unit volume"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(77012; "Quantity to prepare"; Decimal)
        {
            DataClassification = CustomerContent;

            Caption = 'Quantity to Prepare';
            ToolTip = 'Specifies the quantity that needs to be prepared for delivery.';
            trigger OnValidate()
            var
                TripSetup: Record "Trip Setup";
                CompanyLocationInventory: Decimal;
                CompanyLocationCode: Code[20];
                ItemLedgerEntry: Record "Item Ledger Entry";

            begin

                begin
                    // Get company location code from setup
                    if TripSetup.Get() then
                        CompanyLocationCode := TripSetup."Location Code";
                    CompanyLocationInventory := 0;
                    if (Rec."Item" <> '') and (CompanyLocationCode <> '') then begin
                        ItemLedgerEntry.SetCurrentKey("Item No.");
                        ItemLedgerEntry.SetRange("Item No.", Rec."Item");
                        ItemLedgerEntry.SetRange("Location Code", CompanyLocationCode);
                        ItemLedgerEntry.SetRange(Open, true);
                        ItemLedgerEntry.CalcSums("Remaining Quantity");
                        CompanyLocationInventory := ItemLedgerEntry."Remaining Quantity";
                        if "Quantity to prepare" > "Quantity to deliver" then
                            Error('Quantity to prepare cannot exceed the delivery order.');
                        if rec."Quantity to prepare" > CompanyLocationInventory then
                            Error('invetory should be adjusted , quantity cannot be prepared');
                    end;
                end;
                // Ensure that Quantity to Prepare is not negative



            end;





        }

        field(77011; "Quantity prepared"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                // Ensure that Quantity Prepared does not exceed Quantity to Prepare
                if "Quantity prepared" > "Quantity to prepare" then
                    Error('Quantity prepared cannot exceed Quantity to prepare.');

            end;
        }
        field(77013; "item"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            ToolTip = 'Specifies the item number associated with the delivery.';
        }
        field(77014; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(77015; "unit of measure code"; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Unit of Measure Code';
            ToolTip = 'Specifies the unit of measure for the item.';
        }
        field(77016; "Quantity per location"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity per Location';
            ToolTip = 'Specifies the quantity to be delivered at this stop.';
        }
        field(77017; "type"; Option)
        {
            OptionMembers = Sales,Purchase,Transfer;
            DataClassification = CustomerContent;
            Caption = 'Document Type';
            ToolTip = 'Specifies the type of document associated with this vehicle stop.';
        }
    }


    keys
    {
        key(PK; "Fiche No.", "Stop No.")
        {
            Clustered = true;
        }
    }


}
