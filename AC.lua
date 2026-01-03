-- Jalankan ini untuk scan portal yang benar di Lobby
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") and v.Name == "Dungeon" then
        print("--- PORTAL FOUND ---")
        print("Parent: " .. v.Parent.Name)
        print("Full Path: " .. v:GetFullName())
        print("Position: " .. tostring(v.Position))
    end
end
