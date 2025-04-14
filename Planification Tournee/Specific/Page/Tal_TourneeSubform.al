page 50100 "Planning Lines ListPart"
{
    PageType = ListPart;
    SourceTable = "Planning Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Type"; rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Logistic Tour No."; rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; rec."Source ID")
                {
                    ApplicationArea = All;
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; rec."Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rounding Precision"; rec."Qty. Rounding Precision")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rounding Precision (Base)"; rec."Qty. Rounding Precision (Base)")
                {
                    ApplicationArea = All;
                }
                field("Unit Volume"; rec."Unit Volume")
                {
                    ApplicationArea = All;
                }
                field("Gross Weight"; rec."Gross Weight")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; rec."Net Weight")
                {
                    ApplicationArea = All;
                }
                field(Status; rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Project Code"; rec."Project Code")
                {
                    ApplicationArea = All;
                }
                field("Department Code"; rec."Department Code")
                {
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Inventory Posting Group"; rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Dimension Set ID"; rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                }
                field("Planned Date"; rec."Planned Date")
                {
                    ApplicationArea = All;
                }
                field("Expected Shipment Date"; rec."Expected Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Created At"; rec."Created At")
                {
                    ApplicationArea = All;
                }
                field("Created By"; rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Modified At"; rec."Modified At")
                {
                    ApplicationArea = All;
                }
                field("Modified By"; rec."Modified By")
                {
                    ApplicationArea = All;
                }
                field("System ID"; rec."System ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        // area(processing)
        // {
        //     group("Fetch Planning Lines")
        //     {
        //         action("Get Sales Lines")
        //         {
        //             ApplicationArea = All;
        //             Caption = 'Get Sales Lines';
        //             Image = Import;

        //             trigger OnAction()
        //             var
        //                 PlanningLineFetcher: Codeunit "Planning Line Fetcher";
        //             begin
        //                 PlanningLineFetcher.FetchSalesLines(Rec."Document No.");
        //             end;
        //         }

        //         action("Get Purchase Lines")
        //         {
        //             ApplicationArea = All;
        //             Caption = 'Get Purchase Lines';
        //             Image = Import;

        //             trigger OnAction()
        //             var
        //                 PlanningLineFetcher: Codeunit "Planning Line Fetcher";
        //             begin
        //                 PlanningLineFetcher.FetchPurchaseLines(Rec."Document No.");
        //             end;
        //         }

        //         action("Get Transfer Lines")
        //         {
        //             ApplicationArea = All;
        //             Caption = 'Get Transfer Lines';
        //             Image = Import;

        //             trigger OnAction()
        //             var
        //                 PlanningLineFetcher: Codeunit "Planning Line Fetcher";
        //             begin
        //                 PlanningLineFetcher.FetchTransferLines(Rec."Document No.");
        //             end;
        //         }
        //     }
        // }
    }
}

