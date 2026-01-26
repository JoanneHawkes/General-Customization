tableextension 70102 "McD Production BOM Header Ext" extends "Production BOM Header"
{
    fields
    {
        field(50101; McDStatus; Enum "BOM Status")
        {
            Caption = 'Status';

            trigger OnValidate()
            var
                ProdBOMLineRec: Record "Production BOM Line";
                PlanningAssignment: Record "Planning Assignment";
                MfgSetup: Record "Manufacturing Setup";
                ProdBOMCheck: Codeunit "Production BOM-Check";
                IsHandled: Boolean;
                ProdBOMVersion: Record "Production BOM Version";
            begin
                Status := McdStatus;
                RSMUSPrevStatus := Status;
                if (Status <> xRec.Status) and (Status = Status::Certified) then begin
                    ProdBOMLineRec.SetLoadFields(Type, "No.", "Variant Code");
                    ProdBOMLineRec.SetRange("Production BOM No.", "No.");
                    while ProdBOMLineRec.Next() <> 0 do
                        CheckVariantIfMandatory(ProdBOMLineRec);
                    MfgSetup.LockTable();
                    MfgSetup.Get();
                    ProdBOMCheck.ProdBOMLineCheck("No.", '');
                    "Low-Level Code" := 0;
                    ProdBOMCheck.Run(Rec);
                    PlanningAssignment.NewBOM("No.");
                end;
                if Status = Status::Closed then begin
                    if not IsHandled then
                        if Confirm(Text001, false) then begin
                            ProdBOMVersion.SetRange("Production BOM No.", "No.");
                            if ProdBOMVersion.Find('-') then
                                repeat
                                    ProdBOMVersion.Status := ProdBOMVersion.Status::Closed;
                                    ProdBOMVersion.Modify();
                                until ProdBOMVersion.Next() = 0;
                        end else
                            Status := xRec.Status;
                end;

            end;
        }
    }
    local procedure CheckVariantIfMandatory(var ProductionBOMLine: Record "Production BOM Line")
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        Item.SetRange("Production BOM No.", "No.");
        if item.FindFirst() then
            if Item.IsVariantMandatory(ProductionBOMLine.Type = ProductionBOMLine.Type::Item, ProductionBOMLine."No.") then
                ProductionBOMLine.TestField("Variant Code");
    end;

    var
        Text001: Label 'All versions attached to the BOM will be closed. Close BOM?';
}
