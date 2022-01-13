package events.navigation.popups
{

    public class AddPopupSkillRankUpdateEvent extends AddPopupEvent
    {
        private var _skillRankData:Object;

        public function AddPopupSkillRankUpdateEvent(skillRankData:Object):void
        {
            _skillRankData = skillRankData;
            super(PanelMediator.POPUP_SKILL_RANK_UPDATE);
        }

        public function get skillRankData():Object
        {
            return _skillRankData;
        }
    }
}
