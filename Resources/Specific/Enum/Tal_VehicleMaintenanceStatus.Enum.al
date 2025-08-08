enum 73552 "Vehicle Maintenance Status"
{
    Extensible = true;
    
    value(0; Planned)
    {
        Caption = 'Planned';
    }
    value(1; Scheduled)
    {
        Caption = 'Scheduled';
    }
    value(2; "In Progress")
    {
        Caption = 'In Progress';
    }
    value(3; Completed)
    {
        Caption = 'Completed';
    }
    value(4; Cancelled)
    {
        Caption = 'Cancelled';
    }
}