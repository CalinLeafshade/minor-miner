-- Editor platform inspector

gui = require('gui')

local pinspector = gui:new({width = 300, height = 600, text = "Editor Inspector", fgColor = Color.DarkGrey, visible = false})


pinspector.mainLayout = gui.layout:new({x = 10, y = 30, fgColor = Color.White,}, pinspector)

pinspector.toolbarLayout = gui.layout:new({x = 0, y = 0, direction = "horizontal"}, pinspector.mainLayout)

pinspector.btnShowPlatform = gui.button:new({text = "Platforms", x=0,y=0, height = 30, width = 100, }, pinspector.toolbarLayout)
pinspector.btnShowEnemy = gui.button:new({text = "Enemies", x=0,y=0, height = 30, width = 100, }, pinspector.toolbarLayout)

pinspector.platformLayout = gui.layout:new({x = 0, y = 0, text = "Platform Editor"}, pinspector.mainLayout)

pinspector.platformBarLayout = gui.layout:new({margin = 0, spacing = 5, border = false, x = 0, y = 0, direction = "horizontal"}, pinspector.platformLayout)

pinspector.btnSelectPlatform = gui.button:new({x=0,y=0, width = 64, height = 20, text="Select"}, pinspector.platformBarLayout)
pinspector.btnNewPlatform = gui.button:new({x=0,y=0, width = 64, height = 20, text="New"}, pinspector.platformBarLayout)
pinspector.btnDeletePlatform = gui.button:new({x=0,y=0, width = 64, height = 20, text="Delete"}, pinspector.platformBarLayout)

gui.hline:new(nil, pinspector.platformLayout)



pinspector.lblPlatformMode = gui.label:new({x=0,y=0,clip = false, text = "Current Mode:"}, pinspector.platformLayout)
pinspector.drawModeSelector = gui.selector:new({text = "Draw Mode: ", choices = {"path", "box"}},pinspector.platformLayout)
pinspector.typeSelector = gui.selector:new({text = "Platform type: ", choices = Editor.PlatformTypes},pinspector.platformLayout)

--pinspector.button1 = gui.button:new({x = 0, y = 0, width = 100, height = 30, text = "hello!"}, pinspector.platformLayout)
--pinspector.textbox1 = gui.textbox:new({x = 0, y = 0, width = 200, height = 20, text = "textbox lol"}, pinspector.platformLayout)
--pinspector.label1 = gui.label:new({x = 0, y = 0, width = 50, height = 50, text = "This is a label"}, pinspector.platformLayout)

pinspector.enemyLayout = gui.layout:new({x = 0, y = 0, visible = false, text = "Enemy Editor"}, pinspector.mainLayout)

pinspector.lblEnemyCount = gui.label:new({x=0,y=0,clip=false,text="Enemy Count: "}, pinspector.enemyLayout)

pinspector.enemySpawnLayout = gui.layout:new({x = 0, y = 0, margin=0, border = false}, pinspector.enemyLayout)
pinspector.spawnSelector = gui.selector:new({text = "Enemy Type: ", width=150, choices = {"uninited"}},pinspector.enemySpawnLayout)
pinspector.btnSpawn = gui.button:new({x = 0, y = 0, width=200, height=20, text="Spawn"}, pinspector.enemySpawnLayout)

pinspector.enemySelectLayout = gui.layout:new({x = 0, y = 0,margin=0,border=false, visible=false }, pinspector.enemyLayout)

pinspector.enemyXYLayout = gui.layout:new({x=0,y=0,direction="horizontal",margin=0,border=false,text="Position"}, pinspector.enemySelectLayout)
pinspector.txtEnemyX = gui.textbox:new({x=0,y=0,label="X: ", width = 100, height = 20, text = ""}, pinspector.enemyXYLayout)
pinspector.txtEnemyY = gui.textbox:new({x=0,y=0,label="Y: ", width = 100, height = 20, text = ""}, pinspector.enemyXYLayout)


pinspector.btnSave = gui.button:new({x = 0,y=0,width = 215,height = 30, text = "Save Room"}, pinspector.mainLayout)


function pinspector.btnSpawn:onClick()
	Enemy.Spawn(pinspector.spawnSelector.choices[pinspector.spawnSelector.selectedIndex], Game.Viewport.x + 160, Game.Viewport.y + 100)
end

function pinspector:update(dt)
	local ml = pinspector.mainLayout
	self.width = ml.width + ml.x * 2
	self.height = ml.height + ml.y + 10
	gui.update(self,dt)
end

function pinspector.drawModeSelector:onChange()
	Editor.DrawMode = self.choices[self.selectedIndex]
end


function pinspector.typeSelector:onChange()
	Editor.Selected.Mode = Editor.PlatformTypes[self.selectedIndex]
end

function pinspector.btnShowPlatform:onClick()
	pinspector.enemyLayout.visible = false
	pinspector.platformLayout.visible = true
	pinspector.btnShowPlatform.toggled = true
	pinspector.btnShowEnemy.toggled = false
	Editor.Mode = "select"
	Editor.Verts = {}
	Editor.TopMode = "platform"
	Editor.Selected = nil
end

function pinspector.btnShowEnemy:onClick()
	pinspector.platformLayout.visible = false
	pinspector.enemyLayout.visible = true
	pinspector.btnShowPlatform.toggled = false
	pinspector.btnShowEnemy.toggled = true
	Editor.Mode = "select"
	Editor.Verts = {}
	Editor.TopMode = "enemy"
	Editor.Selected = nil
end

function pinspector.btnSelectPlatform:onClick()
	Editor.Mode = "select"
	Editor.Verts = {}
end

function pinspector.btnNewPlatform:onClick()
	Editor:NewCollider()
end

function pinspector.btnDeletePlatform:onClick()
	Editor:DeleteCollider()
end

function pinspector.btnSave:onClick()
	Editor:SaveRoom()
end

pinspector.btnShowPlatform:onClick()

return pinspector
