local Locale = {}

local LanguageLibraryPath = "/Script/Engine.Default__KismetInternationalizationLibrary"
local DefaultLanguage = "en"
local CacheSeconds = 1.0

local Strings = {
    en = {
        PanelHint = "F1 close, arrows select, Enter toggle",
        On = "on",
        Off = "off",
        SprintKeepsGrab = "Sprint keeps the held object",
        PullableStims = "Pullable syringes",
        KillMarker = "Kill marker",
        NoAdsSlowdown = "No slowdown while aiming",
        AltScan = "Alt scan highlight",
        PunchSwap = "Punch with a weapon in hand",
        PunchKey = "Punch button",
        Mouse4 = "Mouse 4",
        Mouse5 = "Mouse 5",
        Mouse3 = "Mouse wheel click",
    },
    ru = {
        PanelHint = "F1 закрыть, стрелки выбор, Enter переключить",
        On = "вкл",
        Off = "выкл",
        SprintKeepsGrab = "Бег не роняет предмет",
        PullableStims = "Притягивание шприцев",
        KillMarker = "Маркер убийства",
        NoAdsSlowdown = "Без замедления при прицеливании",
        AltScan = "Подсветка по Alt",
        PunchSwap = "Удар с оружием в руке",
        PunchKey = "Кнопка удара",
        Mouse4 = "Мышь 4",
        Mouse5 = "Мышь 5",
        Mouse3 = "Колесо мыши",
    },
    de = {
        PanelHint = "F1 schließen, Pfeile wählen, Enter umschalten",
        On = "an",
        Off = "aus",
        SprintKeepsGrab = "Sprinten lässt das Objekt nicht fallen",
        PullableStims = "Spritzen heranziehen",
        KillMarker = "Kill-Markierung",
        NoAdsSlowdown = "Keine Verlangsamung beim Zielen",
        AltScan = "Alt-Scan-Hervorhebung",
        PunchSwap = "Schlag mit Waffe in der Hand",
        PunchKey = "Schlagtaste",
        Mouse4 = "Maus 4",
        Mouse5 = "Maus 5",
        Mouse3 = "Mausrad-Klick",
    },
    es = {
        PanelHint = "F1 cerrar, flechas elegir, Enter cambiar",
        On = "activado",
        Off = "desactivado",
        SprintKeepsGrab = "Correr no suelta el objeto",
        PullableStims = "Jeringas atraíbles",
        KillMarker = "Marcador de baja",
        NoAdsSlowdown = "Sin ralentización al apuntar",
        AltScan = "Resaltado del escáner Alt",
        PunchSwap = "Golpe con un arma en la mano",
        PunchKey = "Botón de golpe",
        Mouse4 = "Ratón 4",
        Mouse5 = "Ratón 5",
        Mouse3 = "Clic de la rueda",
    },
    fr = {
        PanelHint = "F1 fermer, flèches choisir, Entrée changer",
        On = "activé",
        Off = "désactivé",
        SprintKeepsGrab = "Le sprint ne lâche pas l'objet",
        PullableStims = "Seringues attirables",
        KillMarker = "Marqueur d'élimination",
        NoAdsSlowdown = "Pas de ralentissement en visant",
        AltScan = "Surbrillance du scan Alt",
        PunchSwap = "Coup de poing avec une arme en main",
        PunchKey = "Bouton de coup",
        Mouse4 = "Souris 4",
        Mouse5 = "Souris 5",
        Mouse3 = "Clic molette",
    },
    ja = {
        PanelHint = "F1 閉じる、矢印 選択、Enter 切り替え",
        On = "オン",
        Off = "オフ",
        SprintKeepsGrab = "ダッシュ中も物を落とさない",
        PullableStims = "注射器を引き寄せる",
        KillMarker = "キルマーカー",
        NoAdsSlowdown = "照準中の減速なし",
        AltScan = "Altスキャンのハイライト",
        PunchSwap = "武器を持ったまま殴る",
        PunchKey = "パンチボタン",
        Mouse4 = "マウス4",
        Mouse5 = "マウス5",
        Mouse3 = "ホイールクリック",
    },
    ko = {
        PanelHint = "F1 닫기, 화살표 선택, Enter 전환",
        On = "켜짐",
        Off = "꺼짐",
        SprintKeepsGrab = "달리기 중 물체를 놓치지 않음",
        PullableStims = "주사기 끌어당기기",
        KillMarker = "처치 표시",
        NoAdsSlowdown = "조준 중 감속 없음",
        AltScan = "Alt 스캔 강조",
        PunchSwap = "무기를 든 채 주먹질",
        PunchKey = "펀치 버튼",
        Mouse4 = "마우스 4",
        Mouse5 = "마우스 5",
        Mouse3 = "휠 클릭",
    },
    pl = {
        PanelHint = "F1 zamknij, strzałki wybór, Enter przełącz",
        On = "wł.",
        Off = "wył.",
        SprintKeepsGrab = "Sprint nie upuszcza przedmiotu",
        PullableStims = "Przyciąganie strzykawek",
        KillMarker = "Znacznik zabicia",
        NoAdsSlowdown = "Brak spowolnienia podczas celowania",
        AltScan = "Podświetlenie skanu Alt",
        PunchSwap = "Cios z bronią w ręku",
        PunchKey = "Przycisk ciosu",
        Mouse4 = "Mysz 4",
        Mouse5 = "Mysz 5",
        Mouse3 = "Kliknięcie kółka",
    },
    ["zh-Hans"] = {
        PanelHint = "F1 关闭，方向键选择，Enter 切换",
        On = "开",
        Off = "关",
        SprintKeepsGrab = "冲刺时不会掉落物体",
        PullableStims = "可吸引注射器",
        KillMarker = "击杀标记",
        NoAdsSlowdown = "瞄准时不减速",
        AltScan = "Alt 扫描高亮",
        PunchSwap = "手持武器时出拳",
        PunchKey = "出拳按键",
        Mouse4 = "鼠标 4",
        Mouse5 = "鼠标 5",
        Mouse3 = "滚轮点击",
    },
    ["zh-Hant"] = {
        PanelHint = "F1 關閉，方向鍵選擇，Enter 切換",
        On = "開",
        Off = "關",
        SprintKeepsGrab = "衝刺時不會掉落物體",
        PullableStims = "可吸引注射器",
        KillMarker = "擊殺標記",
        NoAdsSlowdown = "瞄準時不減速",
        AltScan = "Alt 掃描高亮",
        PunchSwap = "手持武器時出拳",
        PunchKey = "出拳按鍵",
        Mouse4 = "滑鼠 4",
        Mouse5 = "滑鼠 5",
        Mouse3 = "滾輪點擊",
    },
    ["pt-BR"] = {
        PanelHint = "F1 fechar, setas escolher, Enter alternar",
        On = "ligado",
        Off = "desligado",
        SprintKeepsGrab = "Correr não solta o objeto",
        PullableStims = "Seringas atraíveis",
        KillMarker = "Marcador de abate",
        NoAdsSlowdown = "Sem lentidão ao mirar",
        AltScan = "Destaque do scanner Alt",
        PunchSwap = "Soco com arma na mão",
        PunchKey = "Botão de soco",
        Mouse4 = "Mouse 4",
        Mouse5 = "Mouse 5",
        Mouse3 = "Clique da roda",
    },
}

local cachedLanguage = DefaultLanguage
local cachedAt = -CacheSeconds

local function NormalizeLanguage(name)
    if Strings[name] then
        return name
    end
    local base = name:match("^(%a+)")
    if base == "zh" then
        local traditional = name:find("Hant", 1, true) or name:find("TW", 1, true) or name:find("HK", 1, true)
        return traditional and "zh-Hant" or "zh-Hans"
    end
    if base == "pt" then
        return "pt-BR"
    end
    if base and Strings[base] then
        return base
    end
    return DefaultLanguage
end

local function CurrentLanguage()
    local now = os.clock()
    if now - cachedAt < CacheSeconds then
        return cachedLanguage
    end
    cachedAt = now
    local ok, name = pcall(function()
        return StaticFindObject(LanguageLibraryPath):GetCurrentLanguage():ToString()
    end)
    cachedLanguage = ok and type(name) == "string" and NormalizeLanguage(name) or DefaultLanguage
    return cachedLanguage
end

function Locale.Text(id)
    local language = Strings[CurrentLanguage()]
    return language[id] or Strings[DefaultLanguage][id] or id
end

return Locale
