local root = script.Parent.Parent.Parent
local Roact = require(root.roact)


local NumberInput = Roact.Component:extend("NumberInput")
local changeMouse = require(root.gui.changeMouse)

NumberInput.defaultProps = {
    LayoutOrder = 0,
    Position = UDim.new(0, 0),
    Size = UDim.new(0, 30),

    NumType = "all",
    DefaultValue = "0",
    ChangeMouse = true,

    callback = function() end,
}


-- rounds a number to a certain number of decimal places
local function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end


-- removes everything that isn't a number from a string
local function filterToWholeNumber(str)
	return str:gsub('%D','')
end


-- removes everything that isn't a number, -, or . from the string (- is removed if it occurs anywhere other than the beginning)
local function filterToNumber(str)
	local numericString = str:match("%d[%d.]*") or ""
	if str:sub(1,1) == "-" then
		numericString = "-" .. numericString
	end

	return numericString
end


-- much like filterToNumber except that it removes - if its the only character, this should be used when the user is done typing
local function filterForFinalNumber(str)
    local numericString = str:match("%d[%d.]*") or ""

    if str:sub(1,1) == "-" then
        if #str == 1 then
            return ""
        end
		numericString = "-" .. numericString
	end

    -- check if a string has more than 1 .
    if #str - #str:gsub("%.", "") > 1 then
        return ""
    end

    -- add a 0 at the end if the last char is a .
    if str:sub(#str, #str) == "." then
        numericString ..= "0"
    end

    if numericString ~= "" then
        numericString = round(numericString, 5)
    end

	return numericString
end



function NumberInput:init()
    self.input, self.updateInput = Roact.createBinding("")
end


function NumberInput:render()
    self.updateInput(filterForFinalNumber(tostring(self.props.DefaultValue)))

    return Roact.createFragment({
        Input = Roact.createElement("TextBox", {

            AnchorPoint = Vector2.new(0, 0),
            LayoutOrder = self.props.LayoutOrder,
            Size = self.props.Size,
            Position = self.props.Position,

            Text = self.input,
            TextScaled = true,
            ClearTextOnFocus = false,
            BorderSizePixel = 1,

            TextColor3 = self.props.Theme:GetColor(
                Enum.StudioStyleGuideColor.MainText,
                Enum.StudioStyleGuideModifier.Default
            ),
            BackgroundColor3 = self.props.Theme:GetColor(
                Enum.StudioStyleGuideColor.Light,
                Enum.StudioStyleGuideModifier.Default
            ),
            BorderColor3 = self.props.Theme:GetColor(
                Enum.StudioStyleGuideColor.Mid,
                Enum.StudioStyleGuideModifier.Default
            ),


            [Roact.Change.Text] = function(rbx)
                if self.props.NumType == 'whole' then
                    self.updateInput(filterToWholeNumber(rbx.Text))
                else
                    self.updateInput(filterToNumber(rbx.Text))
                end
            end,

            [Roact.Event.MouseEnter] = function()
                changeMouse("IBeam", self.props.ChangeMouse)
            end,
            [Roact.Event.MouseLeave] = function()
                changeMouse("Arrow", self.props.ChangeMouse)
            end,

            [Roact.Event.FocusLost] = function(rbx)
                local newVal = filterForFinalNumber(rbx.Text)

                if newVal ~= "" then
                    self.props.DefaultValue = newVal
                end

                self.updateInput(self.props.DefaultValue)
                self.props.callback(self.props.DefaultValue)
            end,

        },
        {
            Corner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 3),
            }),
            TSize = Roact.createElement("UITextSizeConstraint", {
                MaxTextSize = 12,
            }),
        })
    })

end


return NumberInput