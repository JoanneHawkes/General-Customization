codeunit 70101 McDEventSubscriber
{/*
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
    */
    [EventSubscriber(ObjectType::codeunit, codeunit::"CDC Purch. - Register", OnBeforeModifyPurchHeader, '', false, false)]
    //local procedure OnBeforePurchHeaderInsert(Document: Record "CDC Document"; var PurchHeader: Record "Purchase Header")
    local procedure OnBeforeModifyPurchHeader(var PurchaseHeader: Record "Purchase Header"; var Document: Record "CDC Document")
    Var
        vendor: Record Vendor;
    begin
        if vendor.get(PurchaseHeader."Buy-from Vendor No.") then begin
            PurchaseHeader."Tax Area Code" := vendor."Tax Area Code";
        end;
    end;

    [EventSubscriber(ObjectType::codeunit, codeunit::"Sales Tax Calculate", OnBeforeAddPurchLine, '', false, false)]
    //local procedure OnBeforePurchHeaderInsert(Document: Record "CDC Document"; var PurchHeader: Record "Purchase Header")
    local procedure OnBeforeAddPurchLine(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean);
    Var
        vendor: Record Vendor;
    begin
        if vendor.get(PurchaseLine."Buy-from Vendor No.") then begin
            PurchaseLine."Tax Area Code" := vendor."Tax Area Code";
        end;
    end;

}
