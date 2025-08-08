pageextension 73594 " TAL_PersonResource Card" extends "Resource Card"
{
    layout
    {
        modify(Type)
        { Editable = false; }
        modify(Education)
        { Visible = false; }
        modify("Address 2")
        { Visible = false; }
        modify("Job Title")
        { Visible = false; }
        modify("Social Security No.")
        { Visible = true; }
        moveafter(General; "Personal Data")
        addlast(General)
        {
            group("Person Status")
            {
                field(" Person Status"; rec."Resource Status")
                {
                    ApplicationArea = jobs;
                    Caption = 'Person Status';
                }
            }

            group("Tour Statistics")
            {
                Caption = 'Statistiques des Tournées';

                field("Total Tours"; TotalTours)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre Total de Tournées';
                    ToolTip = 'Affiche le nombre total de tournées associées à cette personne.';
                    Editable = false;
                }

                field("Tours Plannified"; ToursPlannified)
                {
                    ApplicationArea = All;
                    Caption = 'Tournées Planifiées';
                    ToolTip = 'Affiche le nombre de tournées planifiées pour cette personne.';
                    Editable = false;
                    StyleExpr = 'Favorable';
                }

                field("Tours Loading"; ToursLoading)
                {
                    ApplicationArea = All;
                    Caption = 'Tournées en Chargement';
                    ToolTip = 'Affiche le nombre de tournées en cours de chargement pour cette personne.';
                    Editable = false;
                    StyleExpr = 'Attention';
                }

                field("Tours In Progress"; ToursInProgress)
                {
                    ApplicationArea = All;
                    Caption = 'Tournées en Cours';
                    ToolTip = 'Affiche le nombre de tournées en cours pour cette personne.';
                    Editable = false;
                    StyleExpr = 'Favorable';
                }

                field("Tours Completed"; ToursCompleted)
                {
                    ApplicationArea = All;
                    Caption = 'Tournées Terminées';
                    ToolTip = 'Affiche le nombre de tournées terminées pour cette personne.';
                    Editable = false;
                    StyleExpr = 'Favorable';
                }

                field("Tours Stopped"; ToursStopped)
                {
                    ApplicationArea = All;
                    Caption = 'Tournées Arrêtées';
                    ToolTip = 'Affiche le nombre de tournées arrêtées pour cette personne.';
                    Editable = false;
                    StyleExpr = 'Unfavorable';
                }
            }
        }
        addlast("Personal Data")
        {
            field("Identity Card No."; rec."Identity Card No.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the identity card number of the Person.';
            }
            field(" Birth Date "; rec."Birth Date")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the date of birth of the Person.';
            }

            field("additional certifications"; rec."Additional Certifications")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies any additional certifications held by the person ';
            }
            group("Personal Contact")
            {
                field("Phone No."; rec."Phone No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'specifies  the phone number of the person.';
                }
                field("Email"; rec.Email)
                {
                    ApplicationArea = all;
                    ToolTip = 'specifies the email address of the person.';
                }
            }
            group("License Details")
            {
                field("License No."; rec."License No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'specifies the License number of the person';
                }
                field("License Type"; rec."License Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'specifies the type of License held by the person.';
                }
                field("License Expiration Date"; rec."License Expiration Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'specifies the expiration date of license held by the person.';
                }
            }

        }


    }
    actions
    {

    }

    trigger OnOpenPage()
    begin
        if Rec.Type <> Rec.Type::Person then begin
            Rec.Type := Rec.Type::Person;
            Rec.Modify(); // Enregistre la modification dans la base de données
        end;

        UpdateTourStatistics();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateTourStatistics();
    end;

    local procedure UpdateTourStatistics()
    var
        PlanificationHeader: Record "Planification Header";
    begin
        // Réinitialiser les compteurs
        TotalTours := 0;
        ToursPlannified := 0;
        ToursLoading := 0;
        ToursInProgress := 0;
        ToursCompleted := 0;
        ToursStopped := 0;

        // Compter toutes les tournées associées à ce conducteur
        PlanificationHeader.Reset();
        PlanificationHeader.SetRange("Driver No.", Rec."No.");
        TotalTours := PlanificationHeader.Count;

        // Compter les tournées par statut
        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Plannified);
        ToursPlannified := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Loading);
        ToursLoading := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Inprogress);
        ToursInProgress := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Completed);
        ToursCompleted := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Stopped);
        ToursStopped := PlanificationHeader.Count;
    end;

    var
        TotalTours: Integer;
        ToursPlannified: Integer;
        ToursLoading: Integer;
        ToursInProgress: Integer;
        ToursCompleted: Integer;
        ToursStopped: Integer;
}
