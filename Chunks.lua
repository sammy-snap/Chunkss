-- LocalScript

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAX_CHARS = 10000

-- ===== VENTANA PRINCIPAL =====
local gui = Instance.new("ScreenGui")
gui.Name = "ChunkExporter"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0.9, 0, 0.75, 0)
main.Position = UDim2.new(0.05, 0, 0.12, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

-- ===== BARRA DE TÍTULO =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Chunk Exporter — Phase 5: Sammy Snap"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- ===== ÁREA DE STATUS (arriba, chica) =====
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 46)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = main

-- ===== ÁREA DE TEXTO (SCROLLABLE, con lista de labels) =====
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -76)
scrollFrame.Position = UDim2.new(0, 10, 0, 70)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = main

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = scrollFrame

-- ===== STATUS/LOG FUNCTIONS =====
local function status(msg, delay)
	statusLabel.Text = msg
	statusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	task.wait(delay or 0.4)
end

local function errorMsg(msg)
	statusLabel.Text = "[ERROR] " .. msg
	statusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	warn("[ChunkExporter] " .. msg)
end

local function addDebugLine(text, color)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = color or Color3.fromRGB(255, 200, 100)
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = scrollFrame
	return lbl
end

-- Divide un string en pedazos de máximo maxChars
local function splitIntoParts(str, maxChars)
	local parts = {}
	local len = #str
	if len == 0 then
		table.insert(parts, "")
		return parts
	end
	local i = 1
	while i <= len do
		local j = math.min(i + maxChars - 1, len)
		table.insert(parts, str:sub(i, j))
		i = j + 1
	end
	return parts
end

-- Crea un bloque por cada PARTE de un chunk, con su propio botón de copiar
local function addChunkPartBlock(chunkName, partIndex, totalParts, partText)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	container.Parent = scrollFrame

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 6)
	containerCorner.Parent = container

	local containerPad = Instance.new("UIPadding")
	containerPad.PaddingTop = UDim.new(0, 6)
	containerPad.PaddingBottom = UDim.new(0, 6)
	containerPad.PaddingLeft = UDim.new(0, 6)
	containerPad.PaddingRight = UDim.new(0, 6)
	containerPad.Parent = container

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 26)
	header.BackgroundTransparency = 1
	header.Parent = container

	local headerLabel = Instance.new("TextLabel")
	headerLabel.Size = UDim2.new(1, -90, 1, 0)
	headerLabel.BackgroundTransparency = 1
	local title = chunkName
	if totalParts > 1 then
		title = title .. " (Parte " .. partIndex .. "/" .. totalParts .. ")"
	end
	headerLabel.Text = title .. "  [" .. #partText .. " chars]"
	headerLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
	headerLabel.Font = Enum.Font.GothamBold
	headerLabel.TextSize = 13
	headerLabel.TextXAlignment = Enum.TextXAlignment.Left
	headerLabel.Parent = header

	local copyPartBtn = Instance.new("TextButton")
	copyPartBtn.Size = UDim2.new(0, 84, 0, 24)
	copyPartBtn.Position = UDim2.new(1, -84, 0, 1)
	copyPartBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
	copyPartBtn.Text = "Copiar"
	copyPartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	copyPartBtn.Font = Enum.Font.GothamBold
	copyPartBtn.TextSize = 13
	copyPartBtn.Parent = header

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = copyPartBtn

	copyPartBtn.MouseButton1Click:Connect(function()
		local success, err = pcall(function()
			setclipboard(partText)
		end)
		if success then
			copyPartBtn.Text = "¡Listo!"
		else
			copyPartBtn.Text = "Error"
			warn("[ChunkExporter] setclipboard falló: " .. tostring(err))
		end
		task.wait(1.2)
		copyPartBtn.Text = "Copiar"
	end)

	local preview = Instance.new("TextLabel")
	preview.Size = UDim2.new(1, 0, 0, 0)
	preview.Position = UDim2.new(0, 0, 0, 28)
	preview.AutomaticSize = Enum.AutomaticSize.Y
	preview.BackgroundTransparency = 1
	local previewText = partText
	if #previewText > 300 then
		previewText = previewText:sub(1, 300) .. "..."
	end
	preview.Text = (previewText ~= "" and previewText) or "(vacío)"
	preview.TextColor3 = Color3.fromRGB(190, 190, 190)
	preview.Font = Enum.Font.Code
	preview.TextSize = 12
	preview.TextWrapped = true
	preview.TextXAlignment = Enum.TextXAlignment.Left
	preview.TextYAlignment = Enum.TextYAlignment.Top
	preview.Parent = container

	container.Size = UDim2.new(1, 0, 0, 28)
end

-- ===== BÚSQUEDA SEGURA =====
local function safeWaitForChild(parent, name, timeout)
	timeout = timeout or 5
	local ok, result = pcall(function()
		local obj = parent:WaitForChild(name, timeout)
		if not obj then
			error("No se encontró \"" .. name .. "\" dentro de \"" .. parent.Name .. "\" (timeout)")
		end
		return obj
	end)
	if not ok then
		errorMsg(result)
		return nil
	end
	return result
end

-- ===== NAVEGACIÓN =====
-- Ruta: ReplicatedStorage > Controllers > EventController > "Phase 5: Sammy Snap" > Cutscene
local ok, err = pcall(function()

	status("Entrando a ReplicatedStorage...")
	local controllers = safeWaitForChild(RS, "Controllers")
	if not controllers then error("Detenido: falta Controllers") end

	status("Entré a Controllers...")
	local eventController = safeWaitForChild(controllers, "EventController")
	if not eventController then error("Detenido: falta EventController") end

	status("Entré ahora a EventController...")
	local phase5 = safeWaitForChild(eventController, "Phase 5: Sammy Snap")
	if not phase5 then error("Detenido: falta Phase 5: Sammy Snap") end

	status("Entré a Phase 5: Sammy Snap...")
	local cutscene = safeWaitForChild(phase5, "Cutscene")
	if not cutscene then error("Detenido: falta Cutscene") end

	status("Cutscene...")

	local allChildren = cutscene:GetChildren()
	addDebugLine("Hijos totales en Cutscene: " .. #allChildren)
	for _, child in ipairs(allChildren) do
		addDebugLine("  -> " .. child.Name .. " (" .. child.ClassName .. ")", Color3.fromRGB(150,150,150))
	end

	-- ===== OBTENER Y ORDENAR CHUNKS =====
	local chunks = {}
	for _, child in ipairs(allChildren) do
		local num = child.Name:match("^Chunk_(%d+)$")
		if num and child:IsA("StringValue") then
			table.insert(chunks, {n = tonumber(num), name = child.Name, value = child.Value})
		end
	end

	if #chunks == 0 then
		errorMsg("No se encontraron StringValues con formato Chunk_N dentro de Cutscene (revisa la lista de arriba)")
		return
	end

	table.sort(chunks, function(a, b) return a.n < b.n end)

	local totalParts = 0
	for _, c in ipairs(chunks) do
		local parts = splitIntoParts(c.value, MAX_CHARS)
		for i, part in ipairs(parts) do
			addChunkPartBlock(c.name, i, #parts, part)
			totalParts = totalParts + 1
		end
	end

	status("Listo! (" .. #chunks .. " chunks, " .. totalParts .. " partes de copiado)")

end)

if not ok then
	errorMsg("Error inesperado: " .. tostring(err))
end
