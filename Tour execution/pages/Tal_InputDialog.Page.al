page 77057 "Input Dialog"
{
    PageType = StandardDialog;
    Caption = 'Entrée de Texte';

    layout
    {
        area(Content)
        {
            group(DialogGroup)
            {
                ShowCaption = false;

                field(PromptLabel; PromptText)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Style = Strong;
                }

                field(InputField; InputText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    MultiLine = true;
                }
            }
        }
    }

    var
        PromptText: Text[250];
        InputText: Text[250];
        DialogTitle: Text[100];

    procedure SetTexts(NewTitle: Text[100]; NewPrompt: Text[250])
    begin
        DialogTitle := NewTitle;
        PromptText := NewPrompt;
        CurrPage.Caption := DialogTitle;
    end;

    procedure GetInput(): Text[250]
    begin
        exit(InputText);
    end;
}