-- Update chunwan_programs with 2026 RBC Spring Festival Gala program list
-- 2026 RBC 新春晚会节目单

-- Clear existing data
DELETE FROM chunwan_programs;

-- Insert all programs
INSERT INTO chunwan_programs (title, title_en, type, performers, performers_en, description, description_en, sort) VALUES
-- 1. 开场节目
('万马奔腾迎新春', 'Welcome the New Year of the Horse', 'dance',
 '鼓手：刘圳阳 | 舞狮：石磊/赵辛昊/李子瑞/Nicholas | 演唱：黄露露 | 舞蹈：萨省中国舞蹈学校青年组/幼儿组',
 'Drummer: Jackie Liu | Dragon dancers: Lei Shi/Nicholas | Singer: Lulu Huang | Dancers: Chinese Dance School of Saskatchewan',
 '气势磅礴的开场表演', 'Grand opening performance', 1),

-- 2. 乐队表演
('乐队表演 (BLUESTACK Band)', 'BLUESTACK Band', 'song',
 '主唱：Gale Stack/Shane Stack/张玥 | 鼓手：Brad Buettner | 电吉他：Jay Karlson | 键盘手：李翔 | 曲目：吻别 / Running Down A Dream',
 'Vocal: Gale Stack/Shane Stack/Yue Zhang | Drummer: Brad Buettner | Bass: Jay Karlson | Keyboard/Guitar: Xiang Li | Songs: Take Me to Your Heart / Running Down A Dream',
 '经典歌曲联唱', 'Classic song medley', 2),

-- 3. 抽奖环节
('嘉宾发言 / 第一次抽奖（三等奖 3 个）', 'Guest Speech and First Draw (3)', 'prize',
 NULL, NULL,
 '三等奖抽奖环节', 'Third prize draw', 3),

-- 4. 幼儿舞蹈
('里弄记忆', 'Memories of Fun in the Alley', 'dance',
 '演出团体：萨省中国舞蹈学校幼儿组 | 指导老师：颜佳 | 舞蹈演员：Cindy Gao, Maomi Han, Ella Li, Shaun Li, Yingxin Liu, Trevor Lu, Happer Lu, Macie Ma, Sarah Shi, Endian Song, Amanda Wang, Sofia Wang, Tammy Wang, Dolley Zheng',
 'Performed by: Chinese Dance School of Saskatchewan (Junior Group) | Instructed by: Jia Yan',
 '幼儿舞蹈表演', 'Children''s dance performance', 4),

-- 5. 鼓乐表演
('Sky Boys Drummers', 'Sky Boys Drummers', 'percussion',
 NULL, NULL,
 '鼓乐表演', 'Drum performance', 5),

-- 6. 原创歌曲
('汉字美如画', 'Amazing Chinese Characters', 'song',
 '作词：刘勋甲 | 主唱：唐炫智 | 剑舞：Lisa 梁 | 书法：李澳 | 说唱：邱煜宸/张洪睿',
 'Lyrics: Xunjia Liu | Solo: Xuanzhi Tang | Sword Dance: Lisa Liang | Calligraphy: Leo Li | Rap: Yuchen Qiu/Jonathan Zhang',
 '原创歌曲表演', 'Original song performance', 6),

-- 7. 抽奖环节
('第二次抽奖（二等奖 2 个）', 'Second Draw (2)', 'prize',
 NULL, NULL,
 '二等奖抽奖环节', 'Second prize draw', 7),

-- 8. 年代舞
('年代舞', 'Era Dance', 'dance',
 '演出团体：Jazz Me Club',
 'Performed by: Jazz Me Club',
 '经典年代舞蹈', 'Classic era dance', 8),

-- 9. 少儿舞蹈
('如梦令', 'Like a Dream', 'dance',
 '演出团体：萨省中国舞蹈学校少儿组 | 指导老师：颜佳 | 舞蹈演员：Cathering Duchscher, Cindy Gao, Lavonee Gao, Luna Huang, Ella Li, Tammy Wang, Ally Wong, Sophia Wu, Helen Xu, Cici Xu, Iris Yao',
 'Performed by: Chinese Dance School of Saskatchewan (Senior Group) | Instructed by: Jia Yan',
 '少儿舞蹈表演', 'Children''s dance performance', 9),

-- 10. 联唱
('像你这样的朋友（联唱）', 'A Friend Like You (Medley)', 'song',
 '失恋阵线联盟 - 崔嘉存/催俊 Carolyn | Lover Girl - 陈哲怿/王艺婷 Carolyn | Super Star - 黄旎旎/刘心心 | 光年之外 - 黄子语/张皓然 | 像你这样的朋友 - 黄露露/崔家盛等众人 | 伴舞：萨省中国舞蹈学校青年组',
 'Heartbreak Front Alliance - Andrew Cui/Trajan Carolyn | Lover Girl - Mido Chen/Carolyn Wang | Super Star - Nina Huang/Xinxin Liu | Light-years Away - Cathrain Huang/Jackie Zhang | A Friend Like You - Evan Cui | Backup Dancers: Chinese Dance School of Saskatchewan',
 '经典歌曲联唱', 'Classic song medley', 10),

-- 11. 情景剧
('岁月里的花', 'Memories of the Years', 'skit',
 '小薇扮演者：郑雅婷 | 大明扮演者：冯唯思 | 儿童演员：詹思悦/张心馨 | 独唱：向雨舟/周暖暖 | 小合唱：陈春/郝荔茸/吴丽新/赵丹/张立真 | 合唱：春之声合唱团',
 'Actress: Tina Zheng | Actor: Weisi Feng | Children actors: Olivia Zhan/Brooklyn Zhang | Solo: Rainy Xiang/Aria Zhao | Chorus: Spring Choir',
 '情景剧表演', 'Drama performance', 11),

-- 12. 抽奖环节
('第三次抽奖（一等奖 1 个）', 'Third Draw (1)', 'prize',
 NULL, NULL,
 '一等奖抽奖环节', 'First prize draw', 12),

-- 13. 武术表演
('哪吒风云', 'Legend of Nezha', 'martial_arts',
 '演出团体：Academy of Martial Arts',
 NULL,
 '武术表演', 'Martial arts performance', 13),

-- 14. 民族舞联舞
('最炫民族舞', 'Dazzling Ethnic Dance', 'dance',
 '演出团体：萨省中国舞蹈学校 | 指导老师：颜佳 | 儿童演员：Ella Li, Trevor Lu | 青年演员：Yiru Chen, Adela Chuang, Nina Huang, Queenie Liang, Angela Niu, Ellen Qin, Joyce Yang, Zhixuan Zhou, Emma Zhu, Rebecca Zhu | 成人演员：Chun Chen, Yahui Guo, Liyun Jiang, Yue Ke, Xinfeng Liu, Tina Shang, Jinghui Shen, Anna Tang, Ruojing Wang, Yan Wu, Jia Yan, Li Zhang | 特邀演员：Ellen Liang, Xuanzhi Tang',
 'Performed by: Chinese Dance School of Saskatchewan (Youth and Adult Group) | Instructed by: Jia Yan',
 '民族舞蹈联展', 'Ethnic dance showcase', 14),

-- 15. 闭幕曲
('一起向未来', 'Towards the Future', 'song',
 '合唱：春之声合唱团 | 指挥：周弘 | 演员：陈春/郝荔茸/李禕/刘文刚/Lisa Liang/刘新凤/刘哲榕/罗宇/Edward Ma/莫非/渃溪/宋芳妮/孙红英/王谦/吴丽新/徐利军/苑芳/张大勇/张立真/赵丹/赵建伟 | 伴舞：萨省中国舞蹈学校青年组',
 'Chorus: Spring Choir | Backup Dancers: Chinese Dance School of Saskatchewan',
 '闭幕合唱表演', 'Closing chorus performance', 15);
