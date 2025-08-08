
page 73607 GoogleMapCardPart
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
                    CurrPage.GoogleMap.updateMapPosition(0, Rec."Geographic Coordinates");
                end;

            }
        }
    }

}