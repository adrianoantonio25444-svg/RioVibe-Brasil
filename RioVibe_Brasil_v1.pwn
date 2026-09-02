/*
    RIOVIBE BRASIL - GAMEMODE OFICIAL
    Base com Login, SQLite, Banco, Diarias, Missoes e Spawn.
    Todas as coordenadas marcadas como PLACEHOLDER devem ser substituidas
    pelas coordenadas exatas do mapa quando forem definidas.
*/

#define MIXED_SPELLINGS
#define SAMP_COMPAT
#include <open.mp>

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33CC66FF
#define COLOR_PURPLE    0xAA55FFFF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_RED       0xFF4444FF
#define COLOR_BLUE      0x4488FFFF
#define COLOR_ORANGE    0xFF9900FF

#define DIALOG_HELP     1000
#define DIALOG_247     1002
#define DIALOG_REGIAO  1003
#define DIALOG_SERVICO 1004
#define DIALOG_IR      1005

enum E_REGION
{
    REG_NOSSA_SENHORA,
    REG_ARCADIA,
    REG_MEIR,
    REG_NOCTURIA,
    REG_BENGUEIA,
    REG_MARANHAO,
    REG_TURINO
};

new const RegionNames[][] =
{
    "Nossa Senhora",
    "Arcadia",
    "Meir",
    "Nocturia",
    "Bengueia",
    "Maranhao",
    "Turino"
};

/* =========================================================
   COORDENADAS DO MAPA
   =========================================================
   Nossa Senhora ja usa o spawn conhecido da base.
   Os demais pontos estao prontos para receber as coordenadas
   reais do mapa novo.
*/

new const Float:RegionSpawn[][3] =
{
    {2296.5663, 2451.6270, 10.8203}, // Nossa Senhora
    {0.0, 0.0, 3.0},                 // Arcadia - PLACEHOLDER
    {0.0, 0.0, 3.0},                 // Meir - PLACEHOLDER
    {0.0, 0.0, 3.0},                 // Nocturia - PLACEHOLDER
    {0.0, 0.0, 3.0},                 // Bengueia - PLACEHOLDER
    {0.0, 0.0, 3.0},                 // Maranhao - PLACEHOLDER
    {0.0, 0.0, 3.0}                  // Turino - PLACEHOLDER
};

new const Float:BankPos[][3] =
{
    {0.0, 0.0, 3.0}, // Nossa Senhora
    {0.0, 0.0, 3.0}, // Arcadia
    {0.0, 0.0, 3.0}  // Meir
};

new const Float:WeaponShopPos[][3] =
{
    {0.0, 0.0, 3.0}, // Nossa Senhora
    {0.0, 0.0, 3.0}, // Arcadia
    {0.0, 0.0, 3.0}, // Meir
    {0.0, 0.0, 3.0}  // Maranhao
};

new const Float:Shop247Pos[][3] =
{
    {0.0, 0.0, 3.0}, // Nossa Senhora
    {0.0, 0.0, 3.0}, // Arcadia
    {0.0, 0.0, 3.0}, // Meir
    {0.0, 0.0, 3.0}, // Nocturia
    {0.0, 0.0, 3.0}, // Bengueia
    {0.0, 0.0, 3.0}  // Maranhao
};

/* Locais especiais */
new const Float:HospitalPos[3] = {0.0, 0.0, 3.0};      // Arcadia
new const Float:PolicePos[3]   = {0.0, 0.0, 3.0};      // Arcadia
new const Float:MediaPos[3]    = {0.0, 0.0, 3.0};      // Arcadia
new const Float:HouseAuctionPos[3] = {0.0, 0.0, 3.0};  // Arcadia
new const Float:CarAuctionPos[3] = {0.0, 0.0, 3.0};    // Meir
new const Float:DeliveryPos[3] = {0.0, 0.0, 3.0};      // Meir
new const Float:FarmPos[3] = {0.0, 0.0, 3.0};          // Maranhao
new const Float:TruckerPos[3] = {0.0, 0.0, 3.0};       // Maranhao
new const Float:LighthousePos[3] = {0.0, 0.0, 3.0};    // Turino

/* Casas e areas residenciais - quantidade preparada para expansao */
new const Float:EliteHousePos[][3] =
{
    {0.0, 0.0, 3.0}, // Meir
    {0.0, 0.0, 3.0}, // Nocturia
    {0.0, 0.0, 3.0}  // Nocturia
};

new PlayerRegion[MAX_PLAYERS];
new PlayerFaction[MAX_PLAYERS];

#define FACTION_NONE   0
#define FACTION_ROXOS  1
#define FACTION_VERDES 2

stock TeleportToRegion(playerid, regionid)
{
    if(regionid < 0 || regionid >= sizeof(RegionSpawn))
        return 0;

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid,
        RegionSpawn[regionid][0],
        RegionSpawn[regionid][1],
        RegionSpawn[regionid][2]);
    SetPlayerFacingAngle(playerid, 0.0);
    PlayerRegion[playerid] = regionid;

    new msg[96];
    format(msg, sizeof(msg), "Voce chegou em %s.", RegionNames[regionid]);
    SendClientMessage(playerid, COLOR_GREEN, msg);
    return 1;
}

stock CreateWorldLabels()
{
    Create3DTextLabel("BANCO\nNossa Senhora", COLOR_GREEN,
        BankPos[0][0], BankPos[0][1], BankPos[0][2], 20.0, 0, 1);
    Create3DTextLabel("BANCO\nArcadia", COLOR_GREEN,
        BankPos[1][0], BankPos[1][1], BankPos[1][2], 20.0, 0, 1);
    Create3DTextLabel("BANCO\nMeir", COLOR_GREEN,
        BankPos[2][0], BankPos[2][1], BankPos[2][2], 20.0, 0, 1);

    for(new i = 0; i < sizeof(WeaponShopPos); i++)
        Create3DTextLabel("LOJA DE ARMAS",
            COLOR_RED, WeaponShopPos[i][0], WeaponShopPos[i][1],
            WeaponShopPos[i][2], 20.0, 0, 1);

    for(new i = 0; i < sizeof(Shop247Pos); i++)
        Create3DTextLabel("24/7\nComida | Roupa | Kit de Vida | Mascara | Loteria",
            COLOR_YELLOW, Shop247Pos[i][0], Shop247Pos[i][1],
            Shop247Pos[i][2], 20.0, 0, 1);

    Create3DTextLabel("HOSPITAL", COLOR_WHITE,
        HospitalPos[0], HospitalPos[1], HospitalPos[2], 20.0, 0, 1);
    Create3DTextLabel("POLICIA", COLOR_BLUE,
        PolicePos[0], PolicePos[1], PolicePos[2], 20.0, 0, 1);
    Create3DTextLabel("MIDIA", COLOR_YELLOW,
        MediaPos[0], MediaPos[1], MediaPos[2], 20.0, 0, 1);
    Create3DTextLabel("LEILAO DE CASAS", COLOR_ORANGE,
        HouseAuctionPos[0], HouseAuctionPos[1], HouseAuctionPos[2], 20.0, 0, 1);
    Create3DTextLabel("LEILAO DE CARROS", COLOR_ORANGE,
        CarAuctionPos[0], CarAuctionPos[1], CarAuctionPos[2], 20.0, 0, 1);
    Create3DTextLabel("ENTREGADOR", COLOR_GREEN,
        DeliveryPos[0], DeliveryPos[1], DeliveryPos[2], 20.0, 0, 1);
    Create3DTextLabel("FAZENDA", COLOR_GREEN,
        FarmPos[0], FarmPos[1], FarmPos[2], 20.0, 0, 1);
    Create3DTextLabel("CAMINHONEIRO", COLOR_GREEN,
        TruckerPos[0], TruckerPos[1], TruckerPos[2], 20.0, 0, 1);
    Create3DTextLabel("FAROL DE TURINO", COLOR_WHITE,
        LighthousePos[0], LighthousePos[1], LighthousePos[2], 20.0, 0, 1);

    return 1;
}


main()
{
    print("----------------------------------------");
    print("RioVibe Brasil - Base integrada v2");
    print("Login/Registro + SQLite + Diarias + Missoes");
    print("----------------------------------------");
}

/* =========================================================
   CONTAS / SQLITE
   ========================================================= */

#define DIALOG_LOGIN       1100
#define DIALOG_REGISTER    1101
#define DIALOG_DAILY       1102
#define DIALOG_MISSIONS    1103
#define DIALOG_MISSION     1104
#define DIALOG_STATUS      1105

new DB:Database;
new bool:PlayerLogged[MAX_PLAYERS];
new PlayerAccountID[MAX_PLAYERS];

new PlayerMoneyDB[MAX_PLAYERS];
new PlayerBank[MAX_PLAYERS];
new PlayerLevel[MAX_PLAYERS];
new PlayerXP[MAX_PLAYERS];
new PlayerDailyStreak[MAX_PLAYERS];
new PlayerDailyLastDay[MAX_PLAYERS];
new PlayerMission[MAX_PLAYERS];
new PlayerRepairKits[MAX_PLAYERS];
new PlayerBronze[MAX_PLAYERS];
new PlayerSilver[MAX_PLAYERS];
new PlayerGold[MAX_PLAYERS];
new PlayerRioCoins[MAX_PLAYERS];
new PlayerAccessory[MAX_PLAYERS];
new PlayerPermanentVehicle[MAX_PLAYERS];
new PlayerExp2xUntil[MAX_PLAYERS];
new PlayerSalary2xUntil[MAX_PLAYERS];
new PlayerVIPUntil[MAX_PLAYERS];
new PlayerSkinUntil[MAX_PLAYERS];
new PlayerPromoUsed[MAX_PLAYERS];

/* 28 recompensas diarias */
new const DailyRewardText[28][] =
{
    "100 R$",
    "2 EXP",
    "1 Kit de Reparo",
    "Roleta de Bronze",
    "Acessorio: Oculos de Sol",
    "350 R$",
    "Carro temporario: Augen RS6 (48 horas)",
    "500 R$",
    "XP x2 por 12 horas",
    "3 Kits de Reparo",
    "Roleta de Prata",
    "VIP por 1 dia",
    "750 R$",
    "Moto temporaria: Honda X (7 dias)",
    "Salarios x2 por 3 horas",
    "1000 R$",
    "VIP por 3 dias",
    "XP x2 por 24 horas",
    "Skin temporaria por 24 horas",
    "1250 R$",
    "Carro temporario: Ferano 488 GTB (48 horas)",
    "5 Rio Coins",
    "VIP por 5 dias",
    "1500 R$",
    "Roleta de Ouro",
    "15 EXP",
    "2000 R$",
    "Carro permanente: Mitsuba Lanstar X"
};

/* 17 missoes iniciais */
new const MissionName[17][] =
{
    "Novo Estilo",
    "Primeiro Dinheiro",
    "Benfeitor",
    "Transporte Publico",
    "Cartao Bancario",
    "Destaque Individual",
    "Primeiro Capital",
    "Nada e Mais Importante que a Familia",
    "Crescimento na Carreira",
    "Mestre das Estradas",
    "Entusiasta de Automoveis",
    "Cavaleiro Fantasma",
    "Autodefesa",
    "Faroeste",
    "Derby",
    "Compra Seria",
    "Primeira Propriedade"
};

new const MissionObjective[17][] =
{
    "Visite uma loja 24/7.",
    "Ganhe seu primeiro dinheiro no servidor.",
    "Ajude outro jogador.",
    "Use o transporte publico.",
    "Abra sua conta bancaria.",
    "Use /status pela primeira vez.",
    "Junte 1.000 R$.",
    "Visite uma das bases de faccao.",
    "Comece um emprego.",
    "Realize uma viagem entre regioes.",
    "Visite o leilao de carros.",
    "Complete uma entrega.",
    "Compre um item em uma loja.",
    "Visite a regiao de Turino.",
    "Participe de uma atividade do servidor.",
    "Acumule 5.000 R$.",
    "Adquira sua primeira propriedade."
};

new const MissionRewardMoney[17] =
{
    100, 250, 250, 300, 300, 350, 500, 500, 600,
    700, 750, 800, 850, 900, 1000, 1500, 2500
};

stock GetTodayKey()
{
    new year, month, day;
    getdate(year, month, day);
    return (year * 10000) + (month * 100) + day;
}

stock ResetPlayerData(playerid)
{
    PlayerLogged[playerid] = false;
    PlayerAccountID[playerid] = -1;

    PlayerMoneyDB[playerid] = 0;
    PlayerBank[playerid] = 0;
    PlayerLevel[playerid] = 1;
    PlayerXP[playerid] = 0;
    PlayerDailyStreak[playerid] = 0;
    PlayerDailyLastDay[playerid] = 0;
    PlayerMission[playerid] = 0;
    PlayerRepairKits[playerid] = 0;
    PlayerBronze[playerid] = 0;
    PlayerSilver[playerid] = 0;
    PlayerGold[playerid] = 0;
    PlayerRioCoins[playerid] = 0;
    PlayerAccessory[playerid] = 0;
    PlayerPermanentVehicle[playerid] = 0;
    PlayerExp2xUntil[playerid] = 0;
    PlayerSalary2xUntil[playerid] = 0;
    PlayerVIPUntil[playerid] = 0;
    PlayerSkinUntil[playerid] = 0;
    PlayerPromoUsed[playerid] = 0;
    return 1;
}

stock LoadPlayerAccount(playerid, DBResult:result)
{
    PlayerAccountID[playerid] = db_get_field_assoc_int(result, "id");
    PlayerMoneyDB[playerid] = db_get_field_assoc_int(result, "money");
    PlayerBank[playerid] = db_get_field_assoc_int(result, "bank");
    PlayerLevel[playerid] = db_get_field_assoc_int(result, "level");
    PlayerXP[playerid] = db_get_field_assoc_int(result, "xp");
    PlayerDailyStreak[playerid] = db_get_field_assoc_int(result, "daily_streak");
    PlayerDailyLastDay[playerid] = db_get_field_assoc_int(result, "daily_last_day");
    PlayerMission[playerid] = db_get_field_assoc_int(result, "mission");
    PlayerRepairKits[playerid] = db_get_field_assoc_int(result, "repair_kits");
    PlayerBronze[playerid] = db_get_field_assoc_int(result, "bronze");
    PlayerSilver[playerid] = db_get_field_assoc_int(result, "silver");
    PlayerGold[playerid] = db_get_field_assoc_int(result, "gold");
    PlayerRioCoins[playerid] = db_get_field_assoc_int(result, "rio_coins");
    PlayerAccessory[playerid] = db_get_field_assoc_int(result, "accessory");
    PlayerPermanentVehicle[playerid] = db_get_field_assoc_int(result, "permanent_vehicle");
    PlayerExp2xUntil[playerid] = db_get_field_assoc_int(result, "exp2x_until");
    PlayerSalary2xUntil[playerid] = db_get_field_assoc_int(result, "salary2x_until");
    PlayerVIPUntil[playerid] = db_get_field_assoc_int(result, "vip_until");
    PlayerSkinUntil[playerid] = db_get_field_assoc_int(result, "skin_until");
    PlayerPromoUsed[playerid] = db_get_field_assoc_int(result, "promo_used");

    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, PlayerMoneyDB[playerid]);

    PlayerLogged[playerid] = true;
    return 1;
}

stock SavePlayerAccount(playerid)
{
    if(!PlayerLogged[playerid] || PlayerAccountID[playerid] < 0) return 1;

    PlayerMoneyDB[playerid] = GetPlayerMoney(playerid);

    new query[1400];
    format(query, sizeof(query),
        "UPDATE accounts SET money=%d,bank=%d,level=%d,xp=%d,daily_streak=%d,daily_last_day=%d,mission=%d,repair_kits=%d,bronze=%d,silver=%d,gold=%d,rio_coins=%d,accessory=%d,permanent_vehicle=%d,exp2x_until=%d,salary2x_until=%d,vip_until=%d,skin_until=%d,promo_used=%d WHERE id=%d",
        PlayerMoneyDB[playerid],
        PlayerBank[playerid],
        PlayerLevel[playerid],
        PlayerXP[playerid],
        PlayerDailyStreak[playerid],
        PlayerDailyLastDay[playerid],
        PlayerMission[playerid],
        PlayerRepairKits[playerid],
        PlayerBronze[playerid],
        PlayerSilver[playerid],
        PlayerGold[playerid],
        PlayerRioCoins[playerid],
        PlayerAccessory[playerid],
        PlayerPermanentVehicle[playerid],
        PlayerExp2xUntil[playerid],
        PlayerSalary2xUntil[playerid],
        PlayerVIPUntil[playerid],
        PlayerSkinUntil[playerid],
        PlayerPromoUsed[playerid],
        PlayerAccountID[playerid]
    );
    db_query(Database, query);
    return 1;
}

stock FinishPlayerLogin(playerid)
{
    // Finaliza o login sem usar spectate.
    // O jogador recebe o spawn de Nossa Senhora explicitamente.
    if(PlayerLogged[playerid])
    {
        SetSpawnInfo(playerid,
            0,
            7,
            RegionSpawn[REG_NOSSA_SENHORA][0],
            RegionSpawn[REG_NOSSA_SENHORA][1],
            RegionSpawn[REG_NOSSA_SENHORA][2],
            0.0,
            0, 0,
            0, 0,
            0, 0
        );

        SpawnPlayer(playerid);
    }
    return 1;
}

stock ShowLogin(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
        "RioVibe Brasil - Login",
        "Digite sua senha para entrar:",
        "Entrar", "Sair");
    return 1;
}

stock ShowRegister(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
        "RioVibe Brasil - Registro",
        "Sua conta ainda nao existe.\nDigite uma senha para criar sua conta:",
        "Registrar", "Sair");
    return 1;
}

stock CheckAccount(playerid)
{
    new name[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, name, sizeof(name));

    format(query, sizeof(query),
        "SELECT * FROM accounts WHERE name='%s' LIMIT 1",
        name
    );

    new DBResult:result = db_query(Database, query);

    if(db_num_rows(result) > 0)
        ShowLogin(playerid);
    else
        ShowRegister(playerid);

    db_free_result(result);
    return 1;
}

stock CreateAccount(playerid, password[])
{
    new name[MAX_PLAYER_NAME], query[512], hash[65];
    GetPlayerName(playerid, name, sizeof(name));

    if(strlen(password) < 4)
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "RioVibe Brasil - Registro",
            "A senha precisa ter pelo menos 4 caracteres.\nDigite novamente:",
            "Registrar", "Sair");
        return 1;
    }

    /* SHA256_PassHash e usado para nao salvar a senha em texto puro. */
    SHA256_PassHash(password, "RioVibeBrasil", hash, sizeof(hash));

    format(query, sizeof(query),
        "INSERT INTO accounts (name,password,money,bank,level,xp,daily_streak,daily_last_day,mission,repair_kits,bronze,silver,gold,rio_coins,accessory,permanent_vehicle,exp2x_until,salary2x_until,vip_until,skin_until,promo_used) VALUES ('%s','%s',500,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)",
        name, hash
    );

    db_query(Database, query);

    // Recupera o ID da conta criada usando uma consulta compatível.
    new idquery[192];
    format(idquery, sizeof(idquery),
        "SELECT id FROM accounts WHERE name='%s' LIMIT 1",
        name
    );
    new DBResult:idresult = db_query(Database, idquery);
    if(db_num_rows(idresult) > 0)
        PlayerAccountID[playerid] = db_get_field_assoc_int(idresult, "id");
    else
        PlayerAccountID[playerid] = -1;
    db_free_result(idresult);

    PlayerMoneyDB[playerid] = 500;
    PlayerBank[playerid] = 0;
    PlayerLevel[playerid] = 1;
    PlayerXP[playerid] = 0;
    PlayerDailyStreak[playerid] = 0;
    PlayerDailyLastDay[playerid] = 0;
    PlayerMission[playerid] = 0;

    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, 500);

    PlayerLogged[playerid] = true;

    SendClientMessage(playerid, COLOR_GREEN, "Conta criada com sucesso!");
    SendClientMessage(playerid, COLOR_WHITE, "Voce recebeu 500 R$ de dinheiro inicial.");
    SendClientMessage(playerid, COLOR_YELLOW, "Use /diaria e /missoes para comecar.");

    SavePlayerAccount(playerid);
    FinishPlayerLogin(playerid);
    return 1;
}

stock LoginAccount(playerid, password[])
{
    new name[MAX_PLAYER_NAME], query[512], hash[65], stored[65];

    GetPlayerName(playerid, name, sizeof(name));
    SHA256_PassHash(password, "RioVibeBrasil", hash, sizeof(hash));

    format(query, sizeof(query),
        "SELECT * FROM accounts WHERE name='%s' LIMIT 1",
        name
    );

    new DBResult:result = db_query(Database, query);

    if(db_num_rows(result) == 0)
    {
        db_free_result(result);
        SendClientMessage(playerid, COLOR_RED, "Conta nao encontrada.");
        return ShowRegister(playerid);
    }

    db_get_field_assoc(result, "password", stored, sizeof(stored));

    if(strcmp(hash, stored, false) != 0)
    {
        db_free_result(result);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "RioVibe Brasil - Login",
            "Senha incorreta.\nDigite novamente:",
            "Entrar", "Sair");
        return 1;
    }

    LoadPlayerAccount(playerid, result);
    db_free_result(result);

    SendClientMessage(playerid, COLOR_GREEN, "Login realizado com sucesso!");
    SendClientMessage(playerid, COLOR_WHITE, "Use /diaria para sua recompensa de login.");

    FinishPlayerLogin(playerid);
    return 1;
}

/* =========================================================
   RECOMPENSAS DIARIAS
   ========================================================= */

stock GiveDailyReward(playerid, day)
{
    switch(day)
    {
        case 1: GivePlayerMoney(playerid, 100);
        case 2: PlayerXP[playerid] += 2;
        case 3: PlayerRepairKits[playerid] += 1;
        case 4: PlayerBronze[playerid] += 1;
        case 5: PlayerAccessory[playerid] = 1;
        case 6: GivePlayerMoney(playerid, 350);
        case 7: SendClientMessage(playerid, COLOR_BLUE, "Premio: Augen RS6 temporario por 48 horas.");
        case 8: GivePlayerMoney(playerid, 500);
        case 9: PlayerExp2xUntil[playerid] += 43200;
        case 10: PlayerRepairKits[playerid] += 3;
        case 11: PlayerSilver[playerid] += 1;
        case 12: PlayerVIPUntil[playerid] += 86400;
        case 13: GivePlayerMoney(playerid, 750);
        case 14: SendClientMessage(playerid, COLOR_BLUE, "Premio: Honda X temporaria por 7 dias.");
        case 15: PlayerSalary2xUntil[playerid] += 10800;
        case 16: GivePlayerMoney(playerid, 1000);
        case 17: PlayerVIPUntil[playerid] += 259200;
        case 18: PlayerExp2xUntil[playerid] += 86400;
        case 19: PlayerSkinUntil[playerid] += 86400;
        case 20: GivePlayerMoney(playerid, 1250);
        case 21: SendClientMessage(playerid, COLOR_BLUE, "Premio: Ferano 488 GTB temporario por 48 horas.");
        case 22: PlayerRioCoins[playerid] += 5;
        case 23: PlayerVIPUntil[playerid] += 432000;
        case 24: GivePlayerMoney(playerid, 1500);
        case 25: PlayerGold[playerid] += 1;
        case 26: PlayerXP[playerid] += 15;
        case 27: GivePlayerMoney(playerid, 2000);
        case 28: PlayerPermanentVehicle[playerid] = 1;
    }
    return 1;
}

stock ShowDailyRewards(playerid)
{
    new text[1600], line[128], currentDay;
    currentDay = PlayerDailyStreak[playerid] + 1;

    if(currentDay > 28) currentDay = 28;

    text[0] = EOS;

    for(new i = 0; i < 28; i++)
    {
        if(i + 1 < currentDay)
            format(line, sizeof(line), "%02d | %s | COLETADO\n", i + 1, DailyRewardText[i]);
        else if(i + 1 == currentDay)
            format(line, sizeof(line), "%02d | %s | DISPONIVEL\n", i + 1, DailyRewardText[i]);
        else
            format(line, sizeof(line), "%02d | %s | BLOQUEADO\n", i + 1, DailyRewardText[i]);

        strcat(text, line, sizeof(text));
    }

    ShowPlayerDialog(playerid, DIALOG_DAILY, DIALOG_STYLE_MSGBOX,
        "RECOMPENSA DE LOGIN",
        text,
        "COLETAR", "FECHAR");
    return 1;
}

stock ClaimDailyReward(playerid)
{
    if(!PlayerLogged[playerid])
        return SendClientMessage(playerid, COLOR_RED, "Voce precisa estar logado.");

    new today = GetTodayKey();

    if(PlayerDailyLastDay[playerid] == today)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "Voce ja coletou a recompensa de hoje.");
        return 1;
    }

    if(PlayerDailyLastDay[playerid] != 0)
    {
        PlayerDailyStreak[playerid]++;

        if(PlayerDailyStreak[playerid] >= 28)
            PlayerDailyStreak[playerid] = 0;
    }
    else
    {
        PlayerDailyStreak[playerid] = 0;
    }

    new rewardDay = PlayerDailyStreak[playerid] + 1;

    GiveDailyReward(playerid, rewardDay);
    PlayerDailyLastDay[playerid] = today;

    SavePlayerAccount(playerid);

    new msg[160];
    format(msg, sizeof(msg),
        "Recompensa do Dia %d recebida: %s",
        rewardDay, DailyRewardText[rewardDay - 1]
    );
    SendClientMessage(playerid, COLOR_GREEN, msg);

    return 1;
}

/* =========================================================
   MISSOES
   ========================================================= */

stock ShowMissionList(playerid)
{
    new text[1800], line[150];

    format(text, sizeof(text),
        "LISTA DE MISSOES (PROGRESSO: %d/17)\n\n",
        PlayerMission[playerid]
    );

    for(new i = 0; i < 17; i++)
    {
        if(i < PlayerMission[playerid])
            format(line, sizeof(line), "[CONCLUIDA] %d. %s\n", i + 1, MissionName[i]);
        else if(i == PlayerMission[playerid])
            format(line, sizeof(line), "[ATUAL] %d. %s\n", i + 1, MissionName[i]);
        else
            format(line, sizeof(line), "[BLOQUEADA] %d. %s\n", i + 1, MissionName[i]);

        strcat(text, line, sizeof(text));
    }

    ShowPlayerDialog(playerid, DIALOG_MISSIONS, DIALOG_STYLE_LIST,
        "Missoes Iniciais", text, "Ver", "Fechar");
    return 1;
}

stock ShowCurrentMission(playerid)
{
    if(PlayerMission[playerid] >= 17)
    {
        ShowPlayerDialog(playerid, DIALOG_MISSION, DIALOG_STYLE_MSGBOX,
            "Missoes",
            "Parabens! Voce concluiu todas as 17 missoes iniciais.",
            "OK", "");
        return 1;
    }

    new text[600];
    format(text, sizeof(text),
        "Missao %d de 17\n\nNome: %s\n\nObjetivo:\n%s\n\nRecompensa: %d R$\n\nUse /concluir quando cumprir o objetivo.",
        PlayerMission[playerid] + 1,
        MissionName[PlayerMission[playerid]],
        MissionObjective[PlayerMission[playerid]],
        MissionRewardMoney[PlayerMission[playerid]]
    );

    ShowPlayerDialog(playerid, DIALOG_MISSION, DIALOG_STYLE_MSGBOX,
        "Missao Atual", text, "OK", "");
    return 1;
}

stock CompleteCurrentMission(playerid)
{
    if(PlayerMission[playerid] >= 17)
        return SendClientMessage(playerid, COLOR_YELLOW, "Voce ja concluiu todas as missoes.");

    new mission = PlayerMission[playerid];
    new reward = MissionRewardMoney[mission];

    GivePlayerMoney(playerid, reward);
    PlayerXP[playerid] += 5;
    PlayerMission[playerid]++;

    SavePlayerAccount(playerid);

    new msg[180];
    format(msg, sizeof(msg),
        "Missao concluida: %s | Premio: %d R$ + 5 EXP.",
        MissionName[mission], reward
    );
    SendClientMessage(playerid, COLOR_GREEN, msg);

    if(PlayerMission[playerid] < 17)
    {
        format(msg, sizeof(msg),
            "Proxima missao: %s. Use /missao.",
            MissionName[PlayerMission[playerid]]
        );
        SendClientMessage(playerid, COLOR_YELLOW, msg);
    }
    else
    {
        SendClientMessage(playerid, COLOR_YELLOW, "Voce concluiu as 17 missoes iniciais!");
    }

    return 1;
}

/* =========================================================
   STATUS
   ========================================================= */

stock ShowStatus(playerid)
{
    new text[800];

    format(text, sizeof(text),
        "RioVibe Brasil - STATUS\n\nDinheiro: %d R$\nNivel: %d\nEXP: %d\nMissao: %d/17\nStreak diaria: %d/28\nKits de reparo: %d\nRoleta Bronze: %d\nRoleta Prata: %d\nRoleta Ouro: %d\nRio Coins: %d\nAcessorio: %s\nVeiculo permanente: %s",
        GetPlayerMoney(playerid),
        PlayerLevel[playerid],
        PlayerXP[playerid],
        PlayerMission[playerid],
        PlayerDailyStreak[playerid],
        PlayerRepairKits[playerid],
        PlayerBronze[playerid],
        PlayerSilver[playerid],
        PlayerGold[playerid],
        PlayerRioCoins[playerid],
        PlayerAccessory[playerid] ? "Oculos de Sol" : "Nenhum",
        PlayerPermanentVehicle[playerid] ? "Mitsuba Lanstar X" : "Nenhum"
    );

    ShowPlayerDialog(playerid, DIALOG_STATUS, DIALOG_STYLE_MSGBOX,
        "Meu Status", text, "Fechar", "");
    return 1;
}

/* =========================================================
   UI DE LOCAIS E 24/7
   ========================================================= */

stock ShowRegions(playerid)
{
    new text[512];
    format(text, sizeof(text),
        "Regioes do RioVibe Brasil:\n\n1. Nossa Senhora\n2. Arcadia\n3. Meir\n4. Nocturia\n5. Bengueia\n6. Maranhao\n7. Turino\n\nUse /ajuda para consultar os demais comandos.");
    ShowPlayerDialog(playerid, DIALOG_REGIAO, DIALOG_STYLE_MSGBOX,
        "Regioes", text, "Fechar", "");
    return 1;
}

stock Show247(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_247, DIALOG_STYLE_LIST,
        "Loja 24/7",
        "Comida - 50 R$\nKit de vida - 250 R$\nRoupa - 100 R$\nMascara - 100 R$\nBilhete - 100 R$",
        "Comprar", "Fechar");
    return 1;
}

/* =========================================================
   GAME MODE
   ========================================================= */

public OnGameModeInit()
{
    SetGameModeText("RioVibe Brasil");
    EnableStuntBonusForAll(false);
    UsePlayerPedAnims();
    SetWeather(0);
    SetWorldTime(12);

    Database = db_open("riovibebrasil.db");

    if(Database == DB:0)
    {
        print("[RioVibeBrasil] ERRO: nao foi possivel abrir riovibebrasil.db.");
        return 1;
    }

    db_query(Database,
        "CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT UNIQUE,password TEXT NOT NULL,money INTEGER DEFAULT 500,bank INTEGER DEFAULT 0,level INTEGER DEFAULT 1,xp INTEGER DEFAULT 0,daily_streak INTEGER DEFAULT 0,daily_last_day INTEGER DEFAULT 0,mission INTEGER DEFAULT 0,repair_kits INTEGER DEFAULT 0,bronze INTEGER DEFAULT 0,silver INTEGER DEFAULT 0,gold INTEGER DEFAULT 0,rio_coins INTEGER DEFAULT 0,accessory INTEGER DEFAULT 0,permanent_vehicle INTEGER DEFAULT 0,exp2x_until INTEGER DEFAULT 0,salary2x_until INTEGER DEFAULT 0,vip_until INTEGER DEFAULT 0,skin_until INTEGER DEFAULT 0,promo_used INTEGER DEFAULT 0)"
    );

    AddPlayerClass(7,
        RegionSpawn[REG_NOSSA_SENHORA][0],
        RegionSpawn[REG_NOSSA_SENHORA][1],
        RegionSpawn[REG_NOSSA_SENHORA][2],
        0.0,
        WEAPON_FIST, 0,
        WEAPON_FIST, 0,
        WEAPON_FIST, 0
    );

    CreateWorldLabels();

    print("[RioVibeBrasil] SQLite inicializado.");
    print("[RioVibeBrasil] Sistema de login/registro carregado.");
    print("[RioVibeBrasil] 28 recompensas diarias carregadas.");
    print("[RioVibeBrasil] 17 missoes iniciais carregadas.");

    return 1;
}

public OnGameModeExit()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerLogged[i])
            SavePlayerAccount(i);
    }

    if(Database != DB:0)
        db_close(Database);

    return 1;
}

public OnPlayerConnect(playerid)
{
    ResetPlayerData(playerid);

    PlayerRegion[playerid] = REG_NOSSA_SENHORA;
    PlayerFaction[playerid] = FACTION_NONE;

    SendClientMessage(playerid, COLOR_GREEN, "Bem-vindo ao RioVibe Brasil!");
    SendClientMessage(playerid, COLOR_WHITE, "Verificando sua conta...");

    CheckAccount(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(PlayerLogged[playerid])
        SavePlayerAccount(playerid);

    ResetPlayerData(playerid);
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(!PlayerLogged[playerid])
        return 1;

    SetPlayerPos(playerid,
        RegionSpawn[REG_NOSSA_SENHORA][0],
        RegionSpawn[REG_NOSSA_SENHORA][1],
        RegionSpawn[REG_NOSSA_SENHORA][2]
    );

    SetPlayerFacingAngle(playerid, 0.0);

    SetPlayerCameraPos(playerid,
        RegionSpawn[REG_NOSSA_SENHORA][0] + 5.0,
        RegionSpawn[REG_NOSSA_SENHORA][1] + 5.0,
        RegionSpawn[REG_NOSSA_SENHORA][2] + 3.0
    );

    SetPlayerCameraLookAt(playerid,
        RegionSpawn[REG_NOSSA_SENHORA][0],
        RegionSpawn[REG_NOSSA_SENHORA][1],
        RegionSpawn[REG_NOSSA_SENHORA][2]
    );

    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!PlayerLogged[playerid])
        return 1;

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    SetPlayerPos(playerid,
        RegionSpawn[REG_NOSSA_SENHORA][0],
        RegionSpawn[REG_NOSSA_SENHORA][1],
        RegionSpawn[REG_NOSSA_SENHORA][2]
    );

    PlayerRegion[playerid] = REG_NOSSA_SENHORA;
    return 1;
}

/* =========================================================
   COMANDOS
   ========================================================= */


stock ParseTwoArgs(const input[], command[], commandsize, arg1[], arg1size, arg2[], arg2size)
{
    command[0] = EOS; arg1[0] = EOS; arg2[0] = EOS;
    new len = strlen(input), i = 0, p = 0;
    while(i < len && input[i] != ' ' && p < commandsize - 1) command[p++] = input[i++];
    command[p] = EOS;
    while(i < len && input[i] == ' ') i++;
    p = 0;
    while(i < len && input[i] != ' ' && p < arg1size - 1) arg1[p++] = input[i++];
    arg1[p] = EOS;
    while(i < len && input[i] == ' ') i++;
    p = 0;
    while(i < len && input[i] != ' ' && p < arg2size - 1) arg2[p++] = input[i++];
    arg2[p] = EOS;
    return 1;
}

stock ShowBankStatus(playerid)
{
    new msg[128];
    format(msg, sizeof(msg), "Dinheiro: R$%d | Banco: R$%d", GetPlayerMoney(playerid), PlayerBank[playerid]);
    SendClientMessage(playerid, COLOR_GREEN, msg);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{

    if(!PlayerLogged[playerid])
        return SendClientMessage(playerid, COLOR_RED, "Voce precisa fazer login primeiro.");

    new command[32], arg1[32], arg2[32];
    ParseTwoArgs(cmdtext, command, sizeof(command), arg1, sizeof(arg1), arg2, sizeof(arg2));

    if(!strcmp(command, "/banco", true))
        return ShowBankStatus(playerid);

    if(!strcmp(command, "/dinheiro", true))
    {
        new msg[80];
        format(msg, sizeof(msg), "Voce possui R$%d em maos.", GetPlayerMoney(playerid));
        return SendClientMessage(playerid, COLOR_GREEN, msg);
    }

    if(!strcmp(command, "/depositar", true))
    {
        new value = strval(arg1);
        if(value <= 0) return SendClientMessage(playerid, COLOR_RED, "Uso: /depositar [valor]");
        if(GetPlayerMoney(playerid) < value) return SendClientMessage(playerid, COLOR_RED, "Dinheiro insuficiente.");
        GivePlayerMoney(playerid, -value);
        PlayerBank[playerid] += value;
        SavePlayerAccount(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "Deposito realizado com sucesso.");
    }

    if(!strcmp(command, "/sacar", true))
    {
        new value = strval(arg1);
        if(value <= 0) return SendClientMessage(playerid, COLOR_RED, "Uso: /sacar [valor]");
        if(PlayerBank[playerid] < value) return SendClientMessage(playerid, COLOR_RED, "Saldo bancario insuficiente.");
        PlayerBank[playerid] -= value;
        GivePlayerMoney(playerid, value);
        SavePlayerAccount(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "Saque realizado com sucesso.");
    }

    if(!strcmp(command, "/pagar", true))
    {
        new target = strval(arg1), value = strval(arg2);
        if(arg1[0] == EOS || arg2[0] == EOS) return SendClientMessage(playerid, COLOR_RED, "Uso: /pagar [id] [valor]");
        if(target < 0 || target >= MAX_PLAYERS || !IsPlayerConnected(target)) return SendClientMessage(playerid, COLOR_RED, "Jogador invalido.");
        if(target == playerid) return SendClientMessage(playerid, COLOR_RED, "Voce nao pode pagar a si mesmo.");
        if(value <= 0 || GetPlayerMoney(playerid) < value) return SendClientMessage(playerid, COLOR_RED, "Valor invalido ou dinheiro insuficiente.");
        GivePlayerMoney(playerid, -value);
        GivePlayerMoney(target, value);
        SavePlayerAccount(playerid);
        SavePlayerAccount(target);
        return SendClientMessage(playerid, COLOR_GREEN, "Pagamento realizado com sucesso.");
    }

    if(!strcmp(cmdtext, "/ajuda", true))
    {
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX,
            "RioVibe Brasil - Ajuda",
            "/ajuda - ajuda\n/locais - regioes\n/247 - loja 24/7\n/faccao - sua faccao\n/diaria - recompensas de login\n/missoes - lista de missoes\n/missao - missao atual\n/concluir - concluir missao atual\n/status - seus dados",
            "Fechar", "");
        return 1;
    }

    if(!strcmp(cmdtext, "/locais", true))
        return ShowRegions(playerid);

    if(!strcmp(cmdtext, "/247", true))
        return Show247(playerid);

    if(!strcmp(cmdtext, "/faccao", true))
    {
        if(PlayerFaction[playerid] == FACTION_ROXOS)
            SendClientMessage(playerid, COLOR_PURPLE, "Sua faccao: Roxos.");
        else if(PlayerFaction[playerid] == FACTION_VERDES)
            SendClientMessage(playerid, COLOR_GREEN, "Sua faccao: Verdes.");
        else
            SendClientMessage(playerid, COLOR_WHITE, "Voce ainda nao pertence a uma faccao.");

        return 1;
    }

    if(!strcmp(cmdtext, "/diaria", true))
        return ShowDailyRewards(playerid);

    if(!strcmp(cmdtext, "/missoes", true))
        return ShowMissionList(playerid);

    if(!strcmp(cmdtext, "/missao", true))
        return ShowCurrentMission(playerid);

    if(!strcmp(cmdtext, "/concluir", true))
        return CompleteCurrentMission(playerid);

    if(!strcmp(cmdtext, "/status", true))
        return ShowStatus(playerid);

    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_LOGIN)
    {
        if(!response)
        {
            Kick(playerid);
            return 1;
        }

        return LoginAccount(playerid, inputtext);
    }

    if(dialogid == DIALOG_REGISTER)
    {
        if(!response)
        {
            Kick(playerid);
            return 1;
        }

        return CreateAccount(playerid, inputtext);
    }

    if(!PlayerLogged[playerid])
        return 1;

    if(dialogid == DIALOG_DAILY)
    {
        if(response)
            ClaimDailyReward(playerid);

        return 1;
    }

    if(dialogid == DIALOG_MISSIONS)
    {
        if(response)
            return ShowCurrentMission(playerid);

        return 1;
    }

    if(dialogid == DIALOG_247)
    {
        switch(listitem)
        {
            case 0:
            {
                if(GetPlayerMoney(playerid) < 50)
                    return SendClientMessage(playerid, COLOR_RED, "Dinheiro insuficiente.");

                GivePlayerMoney(playerid, -50);
                SavePlayerAccount(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Comida comprada.");
            }
            case 1:
            {
                if(GetPlayerMoney(playerid) < 250)
                    return SendClientMessage(playerid, COLOR_RED, "Dinheiro insuficiente.");

                GivePlayerMoney(playerid, -250);
                SetPlayerHealth(playerid, 100.0);
                SavePlayerAccount(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Kit de vida usado.");
            }
            case 2:
            {
                if(GetPlayerMoney(playerid) < 100)
                    return SendClientMessage(playerid, COLOR_RED, "Dinheiro insuficiente.");

                GivePlayerMoney(playerid, -100);
                SavePlayerAccount(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Roupa comprada.");
            }
            case 3:
            {
                if(GetPlayerMoney(playerid) < 100)
                    return SendClientMessage(playerid, COLOR_RED, "Dinheiro insuficiente.");

                GivePlayerMoney(playerid, -100);
                SavePlayerAccount(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Mascara comprada.");
            }
            case 4:
            {
                if(GetPlayerMoney(playerid) < 100)
                    return SendClientMessage(playerid, COLOR_RED, "Dinheiro insuficiente.");

                GivePlayerMoney(playerid, -100);
                SavePlayerAccount(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Bilhete de loteria comprado.");
            }
        }

        return 1;
    }

    return 1;
}
