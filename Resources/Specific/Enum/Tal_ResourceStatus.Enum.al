enum 77002 "Resource Status"
{
    Extensible = true;
    Caption = 'Resource Status';

    value(0; Available)
    {
        Caption = 'Available';
    }

    value(1; Assigned)
    {
        Caption = 'Assigned to Mission';
    }

    value(2; InMaintenance)
    {
        Caption = 'In Maintenance';
    }

    value(3; Unavailable)
    {
        Caption = 'Unavailable';
    }

    value(4; OnLeave)
    {
        Caption = 'On Leave';
    }
}
