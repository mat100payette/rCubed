package classes
{
    import by.blooddy.crypto.Base64;
    import com.flashfla.utils.ObjectUtil;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import game.noteskins.*;

    public class NoteskinsList extends EventDispatcher
    {
        private static const NOTE_ASSET_NAMES:Array = ["blue", "red", "yellow", "green", "purple", "pink", "orange", "cyan", "white"];
        private static const NOTE_DIRECTIONS:Array = ["D", "U", "L", "R"];

        public static const CUSTOM_NOTESKIN_DATA:String = "custom_noteskin";
        public static const CUSTOM_NOTESKIN_IMPORT:String = "custom_noteskin_import";
        public static const CUSTOM_NOTESKIN_FILE:String = "custom_noteskin_filename";

        ///- Singleton Instance
        private static var _instance:NoteskinsList = null;
        private static var _externalNoteskins:Vector.<ExternalNoteskin>;

        ///- Private Locals
        private var _isLoaded:Boolean = false;
        private var _isLoading:Boolean = false;
        private var _loadError:Boolean = false;

        private var _pendingSWFNoteskins:Object = {};
        private var _pendingBitmapNoteskinData:Object = {};

        // Map of `Noteskin` objects
        private var _noteskins:Object = {};
        private var _loadedNoteskinCount:int = 0;

        //******************************************************************************************//
        // Core Class Functions
        //******************************************************************************************//

        public function NoteskinsList(en:SingletonEnforcer)
        {
            if (en == null)
                throw Error("Multi-Instance Blocked");
        }

        public static function get instance():NoteskinsList
        {
            if (_instance == null)
                _instance = new NoteskinsList(new SingletonEnforcer());
            return _instance;
        }

        public function getNoteskin(noteskinId:uint):Noteskin
        {
            return _noteskins[noteskinId];
        }

        public function get noteskinCount():int
        {
            return _loadedNoteskinCount;
        }

        /**
         * Gets the loaded status.
         * @return Is loaded & No Load Errors
         */
        public function isLoaded():Boolean
        {
            return _isLoaded && !_loadError;
        }

        /**
         * Is there a load error.
         * @return
         */
        public function isError():Boolean
        {
            return _loadError;
        }

        /**
         * Called when a a noteskin is loaded.
         * Triggers a LOAD_COMPLETE when the total noteskins matchs the loaded noteskins.
         */
        private function loadComplete():void
        {
            // Check for any pending noteskin data
            var hasPendingData:Boolean = false;
            var pendingElement:Object;

            for (pendingElement in _pendingBitmapNoteskinData)
            {
                hasPendingData = true;
                break;
            }

            if (!hasPendingData)
            {
                for (pendingElement in _pendingBitmapNoteskinData)
                {
                    hasPendingData = true;
                    break;
                }
            }

            // Not all done yet
            if (hasPendingData)
                return;

            // All Noteskins loaded.
            if (_loadedNoteskinCount > 0 && !_loadError)
            {
                _isLoaded = true;
                dispatchEvent(new Event(Constant.LOAD_COMPLETE));
            }
            // No Loaded Noteskins or loading error
            else
            {
                _loadError = true;
                dispatchEvent(new Event(Constant.LOAD_ERROR));
            }
        }

        /**
         * Load the Noteskins data.
         */
        public function load():void
        {
            // Load New
            _isLoading = true;
            _isLoaded = false;
            _loadError = false;
            _noteskins = {};

            const embeddedNoteskins:Vector.<IEmbeddedNoteskin> = new <IEmbeddedNoteskin>[new EmbeddedNoteskin1(),
                new EmbeddedNoteskin2(),
                new EmbeddedNoteskin3(),
                new EmbeddedNoteskin4(),
                new EmbeddedNoteskin5(),
                new EmbeddedNoteskin6(),
                new EmbeddedNoteskin7(),
                new EmbeddedNoteskin8(),
                new EmbeddedNoteskin9(),
                new EmbeddedNoteskin10()];

            for each (var embeddedNoteskin:IEmbeddedNoteskin in embeddedNoteskins)
            {
                _pendingSWFNoteskins[embeddedNoteskin.id] = embeddedNoteskin.noteskin;
                loadNoteskinSWF(embeddedNoteskin.id, embeddedNoteskin.bytes);
            }

            loadCustomNoteskin();
        }

        //******************************************************************************************//
        // Providers
        //******************************************************************************************//

        /**
         * Gets all loaded noteskin data.
         * @return
         */
        public function get noteskins():Object
        {
            return _noteskins;
        }

        /**
         * Gets a single noteskin data, or the default noteskin if the requested
         * noteskin is null.
         * @param noteskin
         * @return
         */
        public function getInfo(noteskinId:uint):Object
        {
            if (_noteskins[noteskinId] != null)
                return _noteskins[noteskinId];

            return _noteskins[1];
        }

        /**
         * Gets the Note Sprite from the noteskin.
         * This assumes verifyNoteskin has filled in any holes in the data to
         * prevent null references and as such isn't checked here for gameplay speed.
         * @param noteskin
         * @param color
         * @param direction
         * @return
         */
        public function getNoteSprite(noteskinId:uint, color:String, direction:String):Sprite
        {
            // Is requested noteskin is missing, fallback to Default
            if (_noteskins[noteskinId] == null)
                noteskinId = 1;

            const noteskin:Noteskin = _noteskins[noteskinId];
            const notes:Object = noteskin.notes;

            if (noteskin.type == Noteskin.TYPE_BITMAP)
                return drawBitmapNote(notes[color][direction]);
            else if (noteskin.type == Noteskin.TYPE_SWF)
                return new notes[color][direction];

            return null;
        }

        /**
         * Gets the Receptor Movieclip from the noteskin.
         * This assumes verifyNoteskin has filled in any holes in the data to
         * prevent null references and as such isn't checked here for gameplay speed.
         * @param noteskin
         * @param color
         * @param direction
         * @return
         */
        public function getReceptor(noteskinId:uint, direction:String):MovieClip
        {
            // Is requested noteskin is missing, fallback to Default
            if (_noteskins[noteskinId] == null)
                noteskinId = 1;

            const noteskin:Noteskin = _noteskins[noteskinId];
            const receptor:Object = noteskin.receptor;

            if (noteskin.type == Noteskin.TYPE_BITMAP)
                return new GameReceptor(direction, receptor[direction]);
            else if (noteskin.type == Noteskin.TYPE_SWF)
                return new receptor[direction];

            return null;
        }

        /**
         * Draws a Notes BitmapData into a new sprite.
         * @param bmd BitmapData
         * @return
         */
        private function drawBitmapNote(bmd:BitmapData):Sprite
        {
            const noteSprite:Sprite = new Sprite();
            noteSprite.graphics.beginBitmapFill(bmd, null, false);
            noteSprite.graphics.drawRect(0, 0, bmd.width, bmd.height);
            noteSprite.graphics.endFill();
            noteSprite.cacheAsBitmap = true;
            noteSprite.cacheAsBitmapMatrix = new Matrix();
            noteSprite.mouseEnabled = false;
            noteSprite.doubleClickEnabled = false;
            noteSprite.tabEnabled = false;

            return noteSprite;
        }

        /**
         * Checks if noteskin ID is valid.
         * @param noteskin
         * @return
         */
        public function isValid(noteskinId:uint):Boolean
        {
            return _noteskins[noteskinId] != null;
        }

        //******************************************************************************************//
        // SWF Noteskins
        //******************************************************************************************//

        /**
         * Begin loading of a SWF noteskin and marks the type for this noteskin as TYPE_SWF.
         * @param noteID
         */
        private function loadNoteskinSWF(noteskinId:uint, bytes:ByteArray):void
        {
            const _swfloader:DynamicLoader = new DynamicLoader();
            _swfloader.contentLoaderInfo.addEventListener(Event.COMPLETE, onNoteskinSWFLoaded);
            _swfloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onNoteskinSWFLoadFailed);
            _swfloader.loadBytes(bytes, AirContext.getLoaderContext())
            _swfloader.ID = noteskinId;
        }

        /**
         * Event.COMPLETE for SWF loading complete.
         * @param e
         */
        private function onNoteskinSWFLoaded(e:Event):void
        {
            const loader:DynamicLoader = e.target.loader;
            const noteskinId:uint = loader.ID;
            const noteskin:Noteskin = _pendingSWFNoteskins[noteskinId];

            // Remove Listeners
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onNoteskinSWFLoaded);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onNoteskinSWFLoadFailed);

            // Create Objects
            for each (var assetName:String in NOTE_ASSET_NAMES)
                noteskin.notes[assetName] = getAssetFromTarget(e.target, "assets.noteskin::note_" + assetName);

            noteskin.receptor = getAssetFromTarget(e.target, "assets.noteskin::receptor");

            // Verify noteskin
            if (verifyNoteSkin(noteskin))
            {
                _noteskins[noteskin.id] = noteskin;
                _loadedNoteskinCount++;
            }

            delete _pendingSWFNoteskins[noteskinId];
            loadComplete();
        }

        /**
         * IOErrorEvent.IO_ERROR for SWF loading failure.
         * @param e
         */
        private function onNoteskinSWFLoadFailed(e:Event):void
        {
            const loader:DynamicLoader = e.target.loader;

            // Remove Listeners
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onNoteskinSWFLoaded);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onNoteskinSWFLoadFailed);

            // Remove From List
            delete _pendingSWFNoteskins[loader.ID];

            _loadError = true;
            loadComplete();
        }

        /**
         * Attempts to retrieve a class definition from the given object.
         * Used to retrieve the ntoes and receptors from loaded swfs.
         * @param loader
         * @param assetName
         * @return
         */
        private function getAssetFromTarget(loader:Object, assetName:String):Object
        {
            try
            {
                return {"D": loader.applicationDomain.getDefinition(assetName) as Class};
            }
            catch (e:Error)
            {
            }
            return null;
        }

        //******************************************************************************************//
        // Bitmap Noteskin
        //******************************************************************************************//

        /**
         * Begin loading of a bitmap noteskin and marks the type for this noteskin as TYPE_BITMAP.
         * @param noteID
         */
        private function loadNoteskinBitmap(bitmapNoteskinData:BitmapNoteskinData):void
        {
            if (bitmapNoteskinData.data == null)
                return;

            _pendingBitmapNoteskinData[bitmapNoteskinData.name] = bitmapNoteskinData;

            const bmpString:String = bitmapNoteskinData.data;
            const imgLoader:DynamicLoader = new DynamicLoader();
            imgLoader.ID = 0;

            imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBitmapLoadFailed);
            imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapLoaded);

            try
            {
                imgLoader.loadBytes(Base64.decode(bmpString), AirContext.getLoaderContext());
            }
            catch (e:Error)
            {
                // Remove From List
                delete _pendingBitmapNoteskinData[0];
            }
        }

        /**
         * Event.COMPLETE for bitmap loading complete.
         * @param e
         */
        private function onBitmapLoaded(e:Event):void
        {
            const loader:DynamicLoader = e.currentTarget.loader;
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBitmapLoadFailed);
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapLoaded);

            // TODO: Check conversion
            const noteskinId:uint = loader.ID;
            var noteskinStruct:Object = null;

            const bitmapNoteskinData:BitmapNoteskinData = _pendingBitmapNoteskinData[noteskinId];

            // Get Noteskin Structure
            if (bitmapNoteskinData["rects"] != null)
            {
                if (bitmapNoteskinData["rects"] is String)
                {
                    try
                    {
                        noteskinStruct = JSON.parse(bitmapNoteskinData["rects"]);
                    }
                    catch (e:Error)
                    {
                    }
                }
                else
                    noteskinStruct = bitmapNoteskinData["rects"];
            }

            // Draw Source Bitmap
            const bmp:BitmapData = new BitmapData(loader.width, loader.height, true, 0);
            bmp.draw(loader);

            // Draw Sub-Images for Noteskin
            const dataArray:Object = buildFromBitmapData(bmp, noteskinStruct);
            if (dataArray == null)
            {
                delete _pendingBitmapNoteskinData[noteskinId];
                loadComplete();
                return;
            }

            // Set parameters from structure.
            const dataCell:Array = dataArray["_cell"];
            const noteskinWidth:uint = dataCell[0];
            const noteskinHeight:uint = dataCell[1];
            const noteskinRotation:uint = dataCell[2];

            const noteskin:Noteskin = new Noteskin(noteskinId, bitmapNoteskinData.name, Noteskin.TYPE_BITMAP, noteskinRotation, noteskinWidth, noteskinHeight);

            for (var name:String in dataArray)
            {
                if (name == "receptor")
                    noteskin.receptor = dataArray["receptor"];
                else
                    noteskin.notes[name] = dataArray[name];
            }

            // Verify or Remove
            if (verifyNoteSkin(noteskin))
            {
                _noteskins[noteskin.id] = noteskin;
                _loadedNoteskinCount++;
            }

            delete _pendingBitmapNoteskinData[noteskinId];
            loadComplete();
        }

        /**
         * IOErrorEvent.IO_ERROR for bitmap loading failure.
         * @param e
         */
        private function onBitmapLoadFailed(e:Event):void
        {
            const loader:DynamicLoader = e.currentTarget.loader;
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBitmapLoadFailed);
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapLoaded);

            //- Remove From List
            delete _pendingBitmapNoteskinData[loader.ID];

            _loadError = true;
            loadComplete();
        }

        /**
         * Builds a group of noteskin bitmaps from the source BitmapData
         * following the cell structure
         * @param bmd Source Bitmap Data
         * @param import_struct
         * @return
         */
        public static function buildFromBitmapData(bmd:BitmapData, importStruct:Object):Object
        {
            const struct:Object = NoteskinsStruct.getDefaultStruct();
            const out:Object = {};
            const cuts:Object = {};
            ObjectUtil.merge(struct, importStruct);

            if (importStruct == null || struct["options"] == null || struct["options"]["grid_dim"] == null || struct["blue"] == null || struct["blue"]["D"] == null || struct["blue"]["D"]["c"] == null)
                return null;

            const parsedCell:Array = NoteskinsStruct.parseCellInput(struct["options"]["grid_dim"]);
            const imgW:int = bmd.width;
            const imgH:int = bmd.height;
            const dimW:int = parsedCell[0];
            const dimH:int = parsedCell[1];
            const cellWidth:Number = imgW / dimW;
            const cellHeight:Number = imgH / dimH;
            const cellRotate:Number = NoteskinsStruct.textToRotation(struct["options"]["rotate"], 90);

            out["_cell"] = [cellWidth, cellHeight, cellRotate];

            for (var color:String in struct)
            {
                if (color == "options")
                    continue;

                for (var dir:String in struct[color])
                {
                    if (struct[color][dir]["c"] == "")
                        continue;

                    const notePos:Array = NoteskinsStruct.parseCellInput(struct[color][dir]["c"]);

                    if (!out[color])
                        out[color] = {};

                    // Position outside grid.
                    if (notePos[0] > dimW || notePos[1] > dimH)
                        continue;
                    // Get Existing Bitmap if Cords already used.
                    else if (cuts[notePos[0] + "x" + notePos[1]])
                        out[color][dir] = cuts[notePos[0] + "x" + notePos[1]];
                    else
                    {
                        const noteCanvas:BitmapData = new BitmapData(cellWidth, cellHeight, true, 0);
                        noteCanvas.copyPixels(bmd, new Rectangle(notePos[0] * cellWidth, notePos[1] * cellHeight, cellWidth, cellHeight), new Point(0, 0), null, null, true);
                        out[color][dir] = noteCanvas;
                        cuts[notePos[0] + "x" + notePos[1]] = out[color][dir];
                    }
                }
            }

            return out;
        }

        /**
         * Verfies all required data is a part of a noteskin such as the Receptor and Blue note.
         * Once that is verified, it fills in any gaps for the other colors and directions that
         * might appear with filler data from the Blue note to prevent null errors.
         * @return boolean If Valid Noteskin
         */
        private function verifyNoteSkin(noteskin:Noteskin):Boolean
        {
            // Check if this noteskin has the bare minimum requirements.
            if (noteskin == null)
                return false;

            // Check Receptor
            if (noteskin.receptor == null || noteskin.receptor["D"] == null)
                return false;

            // Check Blue Note
            if (noteskin.notes["blue"] == null || noteskin.notes["blue"]["D"] == null)
                return false;

            // Check Missing Notes and fill from Blue
            for each (var assetName:String in NOTE_ASSET_NAMES)
            {
                if (noteskin.notes[assetName] == null)
                    noteskin.notes[assetName] = noteskin.notes["blue"];

                // Check Missing Directions and fill from Down
                for each (var directionName:String in NOTE_DIRECTIONS)
                {
                    if (noteskin.notes[assetName][directionName] == null)
                        noteskin.notes[assetName][directionName] = noteskin.notes[assetName]["D"];
                }
            }

            // Check Missing Receptor Directions and fill from Down
            for each (var receptorDirection:String in NOTE_DIRECTIONS)
            {
                if (noteskin.receptor[receptorDirection] == null)
                    noteskin.receptor[receptorDirection] = noteskin.receptor["D"];
            }
            return true;
        }

        public function loadCustomNoteskin():void
        {
            var noteskinData:String = LocalStore.getVariable(CUSTOM_NOTESKIN_DATA, null);
            const noteskinImport:String = LocalStore.getVariable(CUSTOM_NOTESKIN_IMPORT, null);
            const noteskinFilename:String = LocalStore.getVariable(CUSTOM_NOTESKIN_FILE, null);

            // Copy Data into Import Slot if coming from old version.
            if (noteskinData != null && noteskinImport == null)
            {
                Logger.debug(this, "Storing Internal Noteskin");
                LocalStore.setVariable(CUSTOM_NOTESKIN_IMPORT, noteskinData);
            }

            // No Data, no Custom Noteskin
            if (noteskinData == null)
            {
                Logger.debug(this, "No Noteskin Data");
                return;
            }

            // Reload External Noteskin if exist
            if (noteskinFilename != null)
            {
                Logger.debug(this, "Reloading External Noteskin: " + noteskinFilename);
                const noteskinJSON:String = AirContext.readTextFile(AirContext.getAppFile(Constant.NOTESKIN_PATH).resolvePath(noteskinFilename));

                if (noteskinJSON == null)
                    LocalStore.deleteVariable(CUSTOM_NOTESKIN_FILE);
                else
                    noteskinData = noteskinJSON;
            }

            parseCustomNoteskin(noteskinData);
        }

        public function parseCustomNoteskin(noteskinJSON:String):void
        {
            if (noteskinJSON == null)
            {
                if (_noteskins[0] != null)
                    delete _noteskins[0];

                return;
            }

            const rawNoteskin:Object = JSON.parse(noteskinJSON);
            const isBitmapNoteskin:Boolean = rawNoteskin["data"] != null;

            if (isBitmapNoteskin)
            {
                const bitmapNoteskinData:BitmapNoteskinData = new BitmapNoteskinData(rawNoteskin["name"], rawNoteskin["data"], rawNoteskin["rects"]);

                loadNoteskinBitmap(bitmapNoteskinData);
            }
        }

        public function get externalNoteskins():Vector.<ExternalNoteskin>
        {
            if (_externalNoteskins == null)
                loadExternalNoteskins();

            return _externalNoteskins;
        }

        public function loadExternalNoteskins():Boolean
        {
            _externalNoteskins = new <ExternalNoteskin>[];

            const noteskinFolder:File = AirContext.getAppFile(Constant.NOTESKIN_PATH);
            if (!noteskinFolder.exists || !noteskinFolder.isDirectory || noteskinFolder.isHidden)
                return false;

            var file:File;
            var fileDataJSON:String;
            var fileData:Object;
            const files:Array = noteskinFolder.getDirectoryListing();

            for (var i:int = 0; i < files.length; i++)
            {
                file = files[i];
                try
                {
                    if (file.type != ".txt")
                        continue;

                    fileDataJSON = AirContext.readTextFile(file);
                    fileData = JSON.parse(fileDataJSON);

                    const extNoteskin:ExternalNoteskin = new ExternalNoteskin();
                    extNoteskin.file = file.name;
                    extNoteskin.data = fileData;
                    extNoteskin.json = fileDataJSON;
                    _externalNoteskins.push(extNoteskin);
                }
                catch (error:Error)
                {
                }
            }

            return true;
        }
    }
}

class SingletonEnforcer
{
}
