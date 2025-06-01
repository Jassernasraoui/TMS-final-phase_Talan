page 77017 "Trip Setup"
{
    ApplicationArea = All;
    Caption = 'Trip Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Trip Setup";
    PageType = Card;
    UsageCategory = Administration;



    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

            }
            group("Number Series")
            {
                Caption = 'Number Series';
                field(Tournee; Rec."Logistic Tour Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifice the Planned Tour Numbers that will be assigned for each saving';
                    TableRelation = "No. Series";
                }
                field(Loading; Rec."Loading Sheet No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifique the Loading Numbers that will be assigned for each saving';
                    TableRelation = "No. Series";
                }
                field(Charing; Rec."Vehicle Charging No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifique the Itinerary Numbers that will be assigned for each saving';
                    TableRelation = "No. Series";
                }
            }
        }
    }

    actions
    {
        // area(Processing)
        // {
        //     action(ActionName)
        //     {

        //         trigger OnAction()
        //         begin

        //         end;
        //     }
        // }
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
        myInt: Integer;
}