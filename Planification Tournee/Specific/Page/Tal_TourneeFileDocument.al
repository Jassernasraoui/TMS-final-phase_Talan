page 50119 "Carte Expédition"
{
    PageType = document;
    SourceTable = "Expédition Header";
    ApplicationArea = All;
    Caption = 'Tournee File ';

    layout
    {
        area(content)
        {
            group("General")
            {
                field("Tour No."; Rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                    Caption = 'Logistic Tour No ';
                    // TableRelation = "Sales & Receivables Setup";
                }

                field("Date de Tournée"; Rec."Date de Tournée")
                {
                    ApplicationArea = All;
                }

                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                    LookupPageId = "Resource List";
                }

                field("Véhicule No."; Rec."Véhicule No.")
                {
                    ApplicationArea = All;
                    LookupPageId = "Vehicule Resource list"; // Page standard de véhicules
                }

                field("Statut"; Rec."Statut")
                {
                    ApplicationArea = All;
                }

                field("Commentaire"; Rec."Commentaire")
                {
                    ApplicationArea = All;
                }
            }

            part("Tour Planning Line"; "Planning Lines ListPart")
            {
                // ApplicationArea = Basic, Suite;
                // SubPageLink = "Document No." = field("No.");
            }
        }


    }


    actions
    {

        // area(navigation)
        // {
        //     group(Expédition)
        //     {
        //         action("Liste Expéditions")
        //         {
        //             ApplicationArea = All;
        //             RunObject = page "Liste des Expéditions";
        //             Image = List;
        //         }
        //     }
        // }
    }
}

