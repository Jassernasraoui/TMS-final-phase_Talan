page 73600 "Tal Locations Setup"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Trip Setup";

    layout
    {
        area(content)
        {
            group("Location Setup")
            {
                field("Location Code"; rec."Location Code")
                {
                    ApplicationArea = All;
                    TableRelation = Location;
                    Lookup = true;
                    Style = StrongAccent;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            // Add actions if needed
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec.Insert();
        end;
    end;
}