table 77015 TripScedulingCueTable
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; PrimaryKey; Code[250])
        {

            DataClassification = ToBeClassified;
        }
        field(2; TripScedulingPlannified; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planification Header" where(Statut = FILTER(Plannified)));

        }
        field(3; TripScedulingOnMission; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planification Header" where(Statut = FILTER("loading")));

        }
        field(4; TripScedulingStopped; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planification Header" where(Statut = FILTER(Stopped)));

        }
        field(5; TripExecutionInProgress; Integer)
        {
            Caption = 'In Progress';
            FieldClass = FlowField;
            CalcFormula = count("Tour Execution Tracking" where(Status = const("En Cours")));
            Editable = false;
        }
        field(6; TripExecutionCompleted; Integer)
        {
            Caption = 'Completed';
            FieldClass = FlowField;
            CalcFormula = count("Tour Execution Tracking" where(Status = const("Livré")));
            Editable = false;
        }
        field(7; TripExecutionDelayed; Integer)
        {
            Caption = 'Delayed';
            FieldClass = FlowField;
            CalcFormula = count("Tour Execution Tracking" where(Status = const("Reporté")));
            Editable = false;
        }
        field(8; TripExecutionCancelled; Integer)
        {
            Caption = 'Cancelled';
            FieldClass = FlowField;
            CalcFormula = count("Tour Execution Tracking" where(Status = const("Échoué")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }
}