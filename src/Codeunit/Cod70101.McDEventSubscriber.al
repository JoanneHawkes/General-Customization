codeunit 70101 McDEventSubscriber
{
    [EventSubscriber(ObjectType::Table, Database::"CDC Document", OnAfterRegisterYN, '', false, false)]
    local procedure OnAfterRegisterYN(var Document: Record "CDC Document")
    Var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.SetRange("No.", Document."Created Doc. No.");
        if PurchHeader.FindFirst() then begin
            if Document."Match Status" = Document."Match Status"::Unmatched then
                PurchHeader.McDDocMatched := false
            else
                PurchHeader.McDDocMatched := true;
            PurchHeader.Modify();
        end;
    end;
}
