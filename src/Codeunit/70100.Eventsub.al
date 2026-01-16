// codeunit 70100 Eventsub
// {
//     SingleInstance = true;
//     [EventSubscriber(ObjectType::Table, Database::"BOM Buffer", OnAfterInsertEvent, '', false, false)]
//     local procedure "Calculate BOM Tree_OnAfterFilterBOMBuffer"(var Rec: Record "BOM Buffer")
//     begin
//         if Rec.Indentation = 0 then begin
//             Clear(TopItem);
//             Clear(ParentItem);
//             Clear(ParentItem2);
//             Rec.TopLevelItem := Rec."No.";
//             Rec.ParentItem := Rec."No.";
//             TopItem := Rec."No.";
//             ParentItem := Rec."No.";
//         end;
//         if Rec.Indentation = 1 then begin
//             Rec.TopLevelItem := TopItem;
//             Rec.ParentItem := TopItem;
//             ParentItem := Rec."No.";
//         end;
//         if Rec.Indentation = 2 then begin
//             Rec.TopLevelItem := TopItem;
//             Rec.ParentItem := ParentItem;
//             ParentItem2 := Rec."No.";
//         end;
//         if Rec.Indentation = 3 then begin
//             Rec.TopLevelItem := TopItem;
//             Rec.ParentItem := ParentItem2;
//         end;

//         Rec.Modify();
//     end;

//     var
//         TopItem: Code[20];
//         ParentItem: Code[20];
//         ParentItem2: Code[20];
// }
codeunit 70100 Eventsub
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"BOM Buffer", OnAfterInsertEvent, '', false, false)]
    local procedure CalculateBOMTree_OnAfterInsert(var Rec: Record "BOM Buffer")
    begin
        // Reset hierarchy when top level starts
        if Rec.Indentation = 0 then begin
            Clear(ParentLevels);

            ParentLevels.Add(0, Rec."No.");
            Rec.TopLevelItem := Rec."No.";
            Rec.ParentItem := Rec."No.";
        end else begin
            // Top level always from level 0
            ParentLevels.Get(0, Rec.TopLevelItem);

            // Parent is previous indentation level
            ParentLevels.Get(Rec.Indentation - 1, Rec.ParentItem);
        end;

        // Store current item at its level
        ParentLevels.Set(Rec.Indentation, Rec."No.");

        Rec.Modify();
    end;

    var
        ParentLevels: Dictionary of [Integer, Code[20]];
}
