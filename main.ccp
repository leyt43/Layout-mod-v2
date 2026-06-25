#include <Geode/Geode.hpp>
#include <Geode/modify/LevelEditorLayer.hpp>
#include <cstdlib>

using namespace geode::prelude;

enum class Difficulty { Easy, Medium, Demon };
enum class GameMode { Cube, Ship, Wave };

class $modify(MyAdvancedGeneratorLayer, LevelEditorLayer) {
    inline static Difficulty s_difficulty = Difficulty::Medium;
    inline static GameMode s_gameMode = GameMode::Cube;

    bool init(GJGameLevel* level, bool p1) {
        if (!LevelEditorLayer::init(level, p1)) return false;

        auto sprite = ButtonSprite::create("Adv Gen", "goldFont.fnt", "GJ_button_01.png", 0.7f);
        auto btn = CCMenuItemSpriteExtra::create(sprite, this, menu_selector(MyAdvancedGeneratorLayer::onOpenSettingsMenu));

        auto menu = this->getChildByID("editor-tools-menu");
        if (!menu) {
            menu = CCMenu::create();
            menu->setPosition({100, 100});
            this->addChild(menu, 10);
        }

        menu->addChild(btn);
        menu->updateLayout();

        return true;
    }

    void onOpenSettingsMenu(CCObject* sender) {
        auto popup = createQuickPopup(
            "Mega Generator",
            "Режим, сложность, музыка и декор:",
            "ОТМЕНА", "СОЗДАТЬ ВСЁ",
            [this](FLAlertLayer* alert, bool btn2) {
                if (btn2) this->generateAdvancedLayout();
            },
            false
        );

        auto layer = popup->m_mainLayer;

        auto diffMenu = CCMenu::create();
        diffMenu->setPosition({140, 160});
        diffMenu->setLayout(RowLayout::create()->setGap(10.0f));
        diffMenu->addChild(CCMenuItemSpriteExtra::create(ButtonSprite::create("Easy", "bigFont.fnt", "GJ_button_02.png", 0.5f), this, menu_selector(MyAdvancedGeneratorLayer::setEasy)));
        diffMenu->addChild(CCMenuItemSpriteExtra::create(ButtonSprite::create("Medium", "bigFont.fnt", "GJ_button_04.png", 0.5f), this, menu_selector(MyAdvancedGeneratorLayer::setMedium)));
        diffMenu->addChild(CCMenuItemSpriteExtra::create(ButtonSprite::create("Demon", "bigFont.fnt", "GJ_button_06.png", 0.5f), this, menu_selector(MyAdvancedGeneratorLayer::setDemon)));
        diffMenu->updateLayout();
        layer->addChild(diffMenu);

        auto modeMenu = CCMenu::create();
        modeMenu->setPosition({140, 100});
        modeMenu->setLayout(RowLayout::create()->setGap(10.0f));
        modeMenu->addChild(CCMenuItemSpriteExtra::create(ButtonSprite::create("Cube", "bigFont.fnt", "GJ_button_01.png", 0.5f), this, menu_selector(MyAdvancedGeneratorLayer::setCube)));
        modeMenu->addChild(CCMenuItemSpriteExtra::create(ButtonSprite::create("Ship", "bigFont.fnt", "GJ_button_01.png", 0.5f), this, menu_selector(MyAdvancedGeneratorLayer::setShip)));
        modeMenu->addChild(CCMenuItemSpriteExtra::create(ButtonSprite::create("Wave", "bigFont.fnt", "GJ_button_01.png", 0.5f), this, menu_selector(MyAdvancedGeneratorLayer::setWave)));
        modeMenu->updateLayout();
        layer->addChild(modeMenu);

        popup->show();
    }

    void setEasy(CCObject*) { s_difficulty = Difficulty::Easy; FLAlertLayer::create("генератор", "Сложность: Easy", "ОК")->show(); }
    void setMedium(CCObject*) { s_difficulty = Difficulty::Medium; FLAlertLayer::create("генератор", "Сложность: Medium", "ОК")->show(); }
    void setDemon(CCObject*) { s_difficulty = Difficulty::Demon; FLAlertLayer::create("генератор", "Сложность: Demon", "ОК")->show(); }
    void setCube(CCObject*) { s_gameMode = GameMode::Cube; FLAlertLayer::create("генератор", "Режим: Cube", "ОК")->show(); }
    void setShip(CCObject*) { s_gameMode = GameMode::Ship; FLAlertLayer::create("генератор", "Режим: Ship", "ОК")->show(); }
    void setWave(CCObject*) { s_gameMode = GameMode::Wave; FLAlertLayer::create("генератор", "Режим: Wave", "ОК")->show(); }

    void generateAdvancedLayout() {
        float currentX = 300.0f;
        float currentY = 105.0f;

        int speedTriggers[] = {200, 201, 202, 203};
        int randomSpeed = speedTriggers[std::rand() % 4];
        this->createObject(randomSpeed, {currentX - 50.0f, currentY + 30.0f}, false);

        if (s_gameMode == GameMode::Ship) {
            this->createObject(11, {currentX, currentY + 30.0f}, false); 
            currentX += 100.0f;
        } else if (s_gameMode == GameMode::Wave) {
            this->createObject(660, {currentX, currentY + 30.0f}, false); 
            currentX += 100.0f;
        }

        int gapMultiplier = (s_difficulty == Difficulty::Easy) ? 3 : (s_difficulty == Difficulty::Medium ? 2 : 1);
        int neonDetails[] = {221, 725, 727};
        int backgroundDetails[] = {29, 30, 105};

        for (int i = 0; i < 50; i++) {
            if (i % 7 == 0) {
                this->createObject(899, {currentX, currentY + 200.0f}, false);
                if (i % 14 == 0) {
                    this->createObject(1006, {currentX, currentY + 230.0f}, false);
                }
            }

            if (s_gameMode == GameMode::Cube) {
                int chance = std::rand() % 3;
                if (chance == 0) {
                    this->createObject(1, {currentX, currentY}, false);
                    this->createObject(neonDetails[std::rand() % 3], {currentX, currentY - 15.0f}, false);
                    currentX += (30.0f * gapMultiplier);
                } 
                else if (chance == 1) {
                    this->createObject(1, {currentX, currentY}, false);
                    this->createObject(8, {currentX, currentY + 30.0f}, false);
                    this->createObject(backgroundDetails[std::rand() % 3], {currentX, currentY + 60.0f}, false);
                    currentX += (60.0f * gapMultiplier);
                } 
                else {
                    int spikeId = (s_difficulty == Difficulty::Demon) ? 479 : 8;
                    this->createObject(spikeId, {currentX, currentY}, false);
                    currentX += (90.0f * gapMultiplier);
                }
            }
            else if (s_gameMode == GameMode::Ship) {
                float ceilingY = (s_difficulty == Difficulty::Demon) ? currentY + 110.0f : currentY + 190.0f;
                this->createObject(1, {currentX, currentY}, false);
                this->createObject(1, {currentX, ceilingY}, false);
                this->createObject(1, {currentX, currentY - 30.0f}, false);
                this->createObject(1, {currentX, ceilingY + 30.0f}, false);

                if (std::rand() % 2 == 0) {
                    this->createObject(8, {currentX, currentY + 30.0f}, false);
                } else {
                    this->createObject(8, {currentX, ceilingY - 30.0f}, false);
                }
                currentX += (45.0f * gapMultiplier);
            }
            else if (s_gameMode == GameMode::Wave) {
                if (i % 2 == 0) {
                    this->createObject(1, {currentX, currentY}, false);
                    this->createObject(8, {currentX, currentY + 30.0f}, false);
                    this->createObject(221, {currentX, currentY + 45.0f}, false);
                } else {
                    float waveCeiling = (s_difficulty == Difficulty::Demon) ? currentY + 85.0f : currentY + 150.0f;
                    this->createObject(1, {currentX, waveCeiling}, false);
                    this->createObject(8, {currentX, waveCeiling - 30.0f}, false);
                }
                currentX += (40.0f * gapMultiplier);
            }
        }
        FLAlertLayer::create("Успех!", "Лейаут сгенерирован!", "Посмотреть")->show();
    }
}; 
