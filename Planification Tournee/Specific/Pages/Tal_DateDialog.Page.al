page 73639 "Tal Date Dialog"
{
    PageType = StandardDialog;
    Caption = 'Sélectionnez une date';

    layout
    {
        area(content)
        {
            field(SelectedDate; SelectedDate)
            {
                ApplicationArea = All;
                Caption = 'Date';
                ToolTip = 'Spécifiez la date à utiliser pour le filtre.';
            }
        }
    }

    var
        SelectedDate: Date;

    procedure GetDate(): Date
    begin
        exit(SelectedDate);
    end;

    procedure SetDate(NewDate: Date)
    begin
        SelectedDate := NewDate;
    end;
}