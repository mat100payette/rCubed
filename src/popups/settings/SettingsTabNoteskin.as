package popups.settings
{
    import assets.menu.icons.fa.iconRefresh;
    import classes.Alert;
    import classes.Language;
    import classes.Noteskin;
    import classes.NoteskinsList;
    import classes.UserSettings;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;
    import classes.ui.BoxIcon;
    import classes.ui.Prompt;
    import classes.ui.Text;
    import classes.ui.NoteColorOption;
    import classes.ui.NoteColorComboBoxItem;
    import com.bit101.components.ComboBox;
    import com.flashfla.utils.VectorUtil;
    import com.flashfla.utils.SystemUtil;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.text.TextFormatAlign;
    import game.noteskins.ExternalNoteskin;

    public class SettingsTabNoteskin extends SettingsTabBase
    {
        private var _lang:Language = Language.instance;
        private var _noteskinsList:NoteskinsList = NoteskinsList.instance;

        private var _ignoreNoteskinCombo:Boolean = false;
        private var _noteskinPreview:Sprite;
        private var _previousNoteskinId:int;
        private var _noteColorComboItems:Vector.<NoteColorComboBoxItem> = new <NoteColorComboBoxItem>[];

        private var _optionUseCustomNoteskin:BoxCheck;
        private var _optionNoteskinCombo:ComboBox;
        private var _optionOpenCustomNoteskinEditor:BoxButton;
        private var _optionOpenNoteskinFolder:BoxButton;
        private var _optionImportCustomNoteskin:BoxButton;
        private var _optionExportCustomNoteskin:BoxButton;
        private var _noteskinCheckOptions:Array = [];
        private var _noteColorOptions:Vector.<NoteColorOption> = new <NoteColorOption>[];

        public function SettingsTabNoteskin(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);

            _previousNoteskinId = _settings.noteskinId;

            for (var i:int = 0; i < DEFAULT_OPTIONS.settings.noteColors.length; i++)
            {
                const defaultColorName:String = DEFAULT_OPTIONS.settings.noteColors[i];
                _noteColorComboItems.push(new NoteColorComboBoxItem(_lang.stringSimple("note_colors_" + defaultColorName), defaultColorName));
            }
        }

        override public function get name():String
        {
            return "noteskin";
        }

        override public function openTab():void
        {
            function addCheckOption(noteskinId:int, noteskinName:String, onCheck:Function):void
            {
                new Text(container, xOff + 23, yOff, noteskinName);
                const checkBox:BoxCheck = new BoxCheck(container, xOff + 3, yOff + 3, function(e:Event):void
                {
                    onNoteskinChecked(noteskinId);
                });
                // TODO: Refactor in typed class
                checkBox.noteskinId = noteskinId;

                yOff += 20;

                _noteskinCheckOptions.push(checkBox)
                _options[noteskinId] = checkBox;
            }

            function addNoteskinColorOption(colorIndex:int):void
            {
                const defaultColor:String = DEFAULT_OPTIONS.settings.noteColors[colorIndex];
                const currentColor:String = _settings.noteColors[colorIndex];
                const textLocalStringName:String = "note_colors_" + defaultColor;

                const noteDefaultColorSprite:Sprite = getNoteSprite(xOff + 11, yOff + 11, 22, defaultColor);

                const noteColor:Text = new Text(container, xOff + 25, yOff, _lang.string(textLocalStringName));
                noteColor.width = 95;

                const noteColorCombo:ComboBox = new ComboBox(container, xOff + 125, yOff, _lang.stringSimple(textLocalStringName), VectorUtil.toArray(_noteColorComboItems));
                noteColorCombo.setSize(114, 22);
                noteColorCombo.openPosition = ComboBox.BOTTOM;
                noteColorCombo.fontSize = 11;
                noteColorCombo.numVisibleItems = DEFAULT_OPTIONS.settings.noteColors.length;
                noteColorCombo.addEventListener(Event.SELECT, function(e:Event):void
                {
                    onNoteColorSelected(colorIndex, (noteColorCombo.selectedItem as NoteColorComboBoxItem).colorName);
                });

                const noteColorSprite:Sprite = getNoteSprite(xOff + 255, yOff + 11, 22, currentColor);

                _noteColorOptions[colorIndex] = new NoteColorOption(noteDefaultColorSprite, noteColorSprite, noteColorCombo);

                yOff += 20;
                yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
            }

            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(295, 15);
            container.graphics.lineTo(295, 405);

            var noteskin:Noteskin;
            var i:int;
            var xOff:int = 15;
            var yOff:int = 15;

            _noteskinPreview = getNoteSprite(xOff + 233, yOff + 32, 64, "blue");

            //- Noteskins
            const textNoteskinGroup:Text = new Text(container, xOff, yOff, _lang.string("options_noteskin"), 14);
            textNoteskinGroup.width = 265;
            yOff += 25;

            const noteskins:Object = _noteskinsList.noteskins;
            const noteskinIds:Array = [];

            for each (noteskin in noteskins)
                if (!noteskin.hidden)
                    noteskinIds.push(noteskin.id);

            noteskinIds.sort(Array.NUMERIC);

            for each (var noteskinId:String in noteskinIds)
            {
                noteskin = noteskins[noteskinId];
                // TODO: This also desperately needs Radio buttons logic
                addCheckOption(noteskin.id, noteskin.name, onNoteskinChecked);
            }

            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            // Custom
            noteskin = noteskins[0];
            addCheckOption(0, _lang.string("options_noteskin_custom"), onNoteskinChecked);

            yOff += 30;

            _optionNoteskinCombo = new ComboBox(container, xOff, yOff, "-- Change Custom Noteskin --");
            _optionNoteskinCombo.setSize(240, 22);
            _optionNoteskinCombo.openPosition = ComboBox.BOTTOM;
            _optionNoteskinCombo.fontSize = 11;
            _optionNoteskinCombo.numVisibleItems = 10;
            _optionNoteskinCombo.addEventListener(Event.SELECT, onCustomNoteskinSelected);
            setCustomNoteskinCombo();

            const noteskinComboRefresh:BoxIcon = new BoxIcon(container, xOff + 240, yOff + 1, 20, 20, new iconRefresh(), onNoteskinComboRefresh);
            noteskinComboRefresh.padding = 7;

            yOff += 31;

            new BoxButton(container, xOff, yOff, 125, 29, _lang.string("options_open_noteskin_editor"), 12, onOpenCustomNoteskinEditor);
            new BoxButton(container, xOff + 135, yOff, 125, 29, _lang.string("options_import_noteskin_json"), 12, onImportCustomNoteskinClicked);

            yOff += 39;

            new BoxButton(container, xOff, yOff, 125, 29, _lang.string("options_open_noteskin_folder"), 12, onOpenNoteskinFolder);
            new BoxButton(container, xOff + 135, yOff, 125, 29, _lang.string("options_copy_noteskin_data"), 12, onExportCustomNoteskinClicked);

            /// Col 2
            xOff = 310;
            yOff = 15;

            const gameNoteColorTitle:Text = new Text(container, xOff + 5, yOff, _lang.string("options_note_colors_title"), 14);
            gameNoteColorTitle.width = 265;
            gameNoteColorTitle.align = TextFormatAlign.CENTER;

            yOff += 28;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            for (i = 0; i < DEFAULT_OPTIONS.settings.noteColors.length; i++)
                addNoteskinColorOption(i);
        }

        private function getNoteSprite(xOff:Number, yOff:Number, receptorSize:Number, color:String):Sprite
        {
            const data:Object = _noteskinsList.getInfo(_settings.noteskinId);
            const hasRotation:Boolean = (data.rotation != 0);

            const noteHolder:Sprite = new Sprite();
            noteHolder.x = xOff;
            noteHolder.y = yOff;
            container.addChild(noteHolder);

            const noteSprite:Sprite = _noteskinsList.getNoteSprite(data.id, color, "U");
            noteSprite.x = -(data.width >> 1);
            noteSprite.y = -(data.height >> 1);
            noteHolder.addChild(noteSprite);

            // scale
            if (hasRotation)
                noteHolder.rotation = data.rotation * 2;

            const noteScale:Number = Math.min(1, (receptorSize / Math.max(noteHolder.width, noteHolder.height)));
            noteHolder.scaleX = noteHolder.scaleY = noteScale;
            noteHolder.visible = true;

            return noteHolder;
        }

        private function replaceNoteImage(oldSprite:Sprite, receptorSize:Number, color:String):Sprite
        {
            const xOff:Number = oldSprite.x;
            const yOff:Number = oldSprite.y;

            oldSprite.parent.removeChild(oldSprite);

            return getNoteSprite(xOff, yOff, receptorSize, color);
        }

        private function updateNoteImages():void
        {
            for (var i:int = 0; i < DEFAULT_OPTIONS.settings.noteColors.length; i++)
            {
                const noteColorOption:NoteColorOption = _noteColorOptions[i];
                const defaultColor:String = DEFAULT_OPTIONS.settings.noteColors[i];
                const replacedColor:String = _settings.noteColors[i];

                noteColorOption.defaultSprite = replaceNoteImage(noteColorOption.defaultSprite, 22, defaultColor);
                noteColorOption.replacedSprite = replaceNoteImage(noteColorOption.replacedSprite, 22, replacedColor);
            }

            _noteskinPreview = replaceNoteImage(_noteskinPreview, 64, "blue");
        }

        override public function setValues():void
        {
            // Set Noteskin
            for each (var checkOption:BoxCheck in _noteskinCheckOptions)
                checkOption.checked = (checkOption.noteskinId == _settings.noteskinId);

            for (var i:int = 0; i < DEFAULT_OPTIONS.settings.noteColors.length; i++)
                (_noteColorOptions[i] as NoteColorOption).comboBox.selectedItemByData = _settings.noteColors[i];

            if (_previousNoteskinId != _settings.noteskinId)
            {
                _previousNoteskinId = _settings.noteskinId;
                updateNoteImages();
            }
        }

        private function onNoteskinChecked(noteskinId:int):void
        {
            _settings.noteskinId = noteskinId;
            setValues();
        }

        private function onNoteskinComboRefresh(e:Event):void
        {
            _noteskinsList.loadExternalNoteskins();
            setCustomNoteskinCombo();
        }

        private function onOpenCustomNoteskinEditor(e:Event):void
        {
            navigateToURL(new URLRequest(Constant.NOTESKIN_EDITOR_URL), "_blank");
        }

        private function onOpenNoteskinFolder(e:Event):void
        {
            AirContext.STORAGE_PATH.resolvePath(Constant.NOTESKIN_PATH).openWithDefaultApplication();
        }

        private function onImportCustomNoteskinClicked(e:Event):void
        {
            new Prompt(_parent, 320, _lang.string("popup_noteskin_import_json"), 100, _lang.string("popup_noteskin_import"), e_importNoteskin);
        }

        private function onExportCustomNoteskinClicked(e:Event):void
        {
            const noteskinString:String = LocalStore.getVariable("custom_noteskin", null);
            if (noteskinString == null)
                return;

            const success:Boolean = SystemUtil.setClipboard(noteskinString);
            if (success)
                Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
            else
                Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
        }

        private function onNoteColorSelected(colorIndex:int, newColor:String):void
        {
            const noteColorOption:NoteColorOption = _noteColorOptions[colorIndex];

            _settings.noteColors[colorIndex] = newColor;
            noteColorOption.replacedSprite = replaceNoteImage(noteColorOption.replacedSprite, 22, newColor);
        }

        private function setCustomNoteskinCombo():void
        {
            var extList:Vector.<ExternalNoteskin> = _noteskinsList.externalNoteskins;
            var noteskinList:Array = [];
            var ns:ExternalNoteskin;

            var noteskinData:String = LocalStore.getVariable(NoteskinsList.CUSTOM_NOTESKIN_DATA, null);
            var noteskinImport:String = LocalStore.getVariable(NoteskinsList.CUSTOM_NOTESKIN_IMPORT, null);
            var noteskinFilename:String = LocalStore.getVariable(NoteskinsList.CUSTOM_NOTESKIN_FILE, null);

            if (extList.length > 0)
            {
                for (var i:int = 0; i < extList.length; i++)
                {
                    ns = extList[i];

                    const nsName:String = ns.data.name.indexOf("Custom Export") != -1 ? ns.file.substr(0, ns.file.length - 4) : ns.data.name;

                    noteskinList.push({"label": nsName, "data": extList[i]});
                }
                noteskinList.sortOn("label", Array.CASEINSENSITIVE);
            }

            if (noteskinImport != null)
            {
                if (extList.length > 0)
                    noteskinList.unshift({"label": "------------------------------------", "data": null});

                noteskinList.unshift({"label": "Imported Noteskin", "data": _optionNoteskinCombo});
            }

            _ignoreNoteskinCombo = true;
            _optionNoteskinCombo.items = noteskinList;

            // select combo box index
            if (noteskinFilename != null)
            {
                for (i = 0; i < noteskinList.length; i++)
                {
                    if (noteskinList[i].data != null && (noteskinList[i].data is ExternalNoteskin) && noteskinList[i].data.file == noteskinFilename)
                    {
                        _optionNoteskinCombo.selectedIndex = i;
                        break;
                    }
                }
            }
            else
            {
                _optionNoteskinCombo.selectedIndex = 0;
            }
            _ignoreNoteskinCombo = false;
        }

        private function onCustomNoteskinSelected(e:Event):void
        {
            if (_ignoreNoteskinCombo)
                return;

            const data:Object = e.target.selectedItem.data;
            if (data == null)
                return;

            else if (data == _optionNoteskinCombo)
            {
                const json:String = LocalStore.getVariable(NoteskinsList.CUSTOM_NOTESKIN_IMPORT, null);
                LocalStore.setVariable(NoteskinsList.CUSTOM_NOTESKIN_DATA, json);
                LocalStore.setVariable(NoteskinsList.CUSTOM_NOTESKIN_FILE, null);
            }
            else
            {
                const extNS:ExternalNoteskin = data as ExternalNoteskin;
                LocalStore.setVariable(NoteskinsList.CUSTOM_NOTESKIN_DATA, extNS.json);
                LocalStore.setVariable(NoteskinsList.CUSTOM_NOTESKIN_FILE, extNS.file);
            }

            if (_settings.noteskinId != 0)
            {
                _settings.noteskinId = 0;
                setValues();
            }

            _noteskinsList.loadCustomNoteskin();
            _parent.addEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
        }


        private function e_importNoteskin(noteskinJSON:String):void
        {
            try
            {
                const json:Object = JSON.parse(noteskinJSON);

                LocalStore.setVariable(NoteskinsList.CUSTOM_NOTESKIN_DATA, noteskinJSON);
                LocalStore.setVariable(NoteskinsList.CUSTOM_NOTESKIN_IMPORT, noteskinJSON);
                LocalStore.setVariable(NoteskinsList.CUSTOM_NOTESKIN_FILE, null);

                _noteskinsList.loadCustomNoteskin();
                setCustomNoteskinCombo();

                Alert.add(_lang.string("popup_noteskin_saved"), 90, Alert.GREEN);

                _parent.addEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
            }
            catch (e:Error)
            {
            }
        }

        private function e_delayCustomUpdate(e:Event):void
        {
            // reload images, custom noteskins are async loaded so we just check for them to load
            if (_settings.noteskinId == 0)
            {
                if (_noteskinsList.noteskins[0]["notes"]["blue"] != null)
                {
                    _parent.removeEventListener(Event.ENTER_FRAME, e_delayCustomUpdate);
                    if (_parent != null && _parent.stage != null)
                        updateNoteImages();
                }
            }
        }

        private function noteskinsString():String
        {
            return LocalStore.getVariable("custom_noteskin", null);
        }
    }
}
