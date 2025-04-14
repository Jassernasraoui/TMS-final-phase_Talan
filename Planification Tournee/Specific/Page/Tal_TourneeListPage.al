page 50111 "Tour plannification list"
{
    PageType = List;
    SourceTable = "Planification Header";
    CardPageId = "Planification Document";
    ApplicationArea = Jobs;
    Caption = 'Tour plannification list';
    UsageCategory = lists;
    MultipleNewLines = true;
    AutoSplitKey = true;
    InsertAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Logistic Tour No."; rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                }

                field("Driver No."; rec."Driver No.")
                {
                    ApplicationArea = CustomerContent;
                    Caption = 'Person assigned';
                    // TableRelation = Resource."No." where("Type" = const(Person));
                }

                field("Véhicule No."; rec."Véhicule No.")
                {
                    ApplicationArea = all;
                    Caption = 'Véhicule assigned';
                    // TableRelation = Resource."No." where("Type" = const(Machine));
                }

                field("Statut"; rec.Statut)
                {
                    ApplicationArea = All;
                    // OptionMembers = Planifiée,"En cours",Terminée;
                    OptionCaption = 'Planifiée,En cours,Terminée';
                }
                field("Date de Tournée"; rec."Date de Tournée")
                {
                    ApplicationArea = All;
                }

                field("Commentaire"; rec.Commentaire)
                {
                    ApplicationArea = CustomerContent;
                }

                field("No. Series"; rec."No. Series")
                {
                    Caption = 'No. Series';
                    Editable = false;
                    // TableRelation = "No. Series";
                }

            }
        }
    }
    actions

    {


        area(processing)

        {

            action(CreateNewTour)

            {

                Caption = 'New Tour ';
                ApplicationArea = All;
                Image = Inventory;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    "createnewtour": Record "Planification Header";
                begin
                    Clear(createnewtour);
                    createnewtour.Init();
                    createnewtour.Insert(true);
                    Page.Run(Page::"Planification Document", createnewtour);
                end;

            }
        }
    }



}