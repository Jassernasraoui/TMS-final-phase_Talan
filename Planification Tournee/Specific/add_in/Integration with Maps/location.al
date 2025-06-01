
page 77107 GoogleMapCardPart
{
    CaptionML = ENU = 'Map';
    PageType = CardPart;
    SourceTable = "Planning Lines";

    layout
    {
        area(Content)
        {
            usercontrol(GoogleMap; GoogleMapCtrl)
            {
                trigger ControlReady();
                begin
                    CurrPage.GoogleMap.updateMapPosition(Rec."Country/Region Code", Rec."Geographic Coordinates");
                end;

            }
        }
    }

}