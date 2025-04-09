codeunit 50100 TourneeManagement
{
    // Fonction pour obtenir le prochain numéro de tournée
    /* procedure GetNextTourneeNumber(): Integer
     var
         SetupRec: Record "Sales & Receivables Setup";
         LastTourneeNo: Integer;
     begin
         if SetupRec.Get() then
             LastTourneeNo := SetupRec."Logistic Tour Nos."
         else
             LastTourneeNo += 1;

         // Mise à jour du numéro dans les paramètres
         SetupRec."Logistic Tour Nos." := LastTourneeNo;
         SetupRec.Modify();

         exit(LastTourneeNo);
     end;*/

    // Fonction pour attribuer un numéro à un enregistrement d'expédition
    // procedure AssignTourneeNumberToTourneeFile(var TourneeRec: Record "Expédition Header")
    // var
    //     NextTourneeNo: Integer;
    // begin
    //     NextTourneeNo := GetNextTourneeNumber();

    //     // Vérifie si ce numéro est déjà utilisé dans Expédition Header
    //     if TourneeRec.Get(NextTourneeNo) then
    //         Error('Le numéro de tournée %1 existe déjà.', NextTourneeNo);

    //     TourneeRec."Logistic Tour No." := NextTourneeNo;
    //     TourneeRec.Modify();
    // end;
}
