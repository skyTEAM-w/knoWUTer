package cj_res_entry

import std.collection.*

public class AppString {
	public var EntryAbility_desc = 16777218
	public var EntryAbility_label = 16777219
	public var app_name = 16777216
	public var bottom_text_course = 16777220
	public var bottom_text_home = 16777221
	public var bottom_text_service = 16777222
	public var bottom_text_tools = 16777223
	public var bottom_text_user = 16777224
	public var module_desc = 16777225
	public var page_show = 16777266
	public var text_course_table = 16777226
	public var text_home = 16777227
	public var text_service = 16777228
	public var text_tools = 16777229
	public var text_user_setting = 16777271
	public var tool_electric_charge = 16777230
}

public class AppColor {
	public var bottom_tab_background_color = 16777231
	public var bottom_text_color_normal = 16777232
	public var bottom_text_color_selected = 16777233
	public var normal_background_grey = 16777234
	public var service_block_background = 16777235
	public var service_list_background = 16777281
	public var start_window_background = 16777236
	public var swiper_dot_color = 16777237
	public var swiper_dot_color_selected = 16777238
	public var whut_blue = 16777248
	public var whut_yellow = 16777272
}

public class AppFloat {
	public var border_radius = 16777239
	public var bottom_font_size = 16777240
	public var component_title_size = 16777241
	public var component_title_weight = 16777242
}

public class AppMedia {
	public var app_icon = 16777217
	public var background = 16777243
	public var banner_campus_map = 16777244
	public var banner_full_text_search = 16777245
	public var banner_info_gate = 16777246
	public var foreground = 16777247
	public var ic_arrow_back = 16777267
	public var ic_arrow_right_up_and_square = 16777249
	public var ic_public_app = 16777250
	public var ic_public_app_filled = 16777251
	public var ic_public_calendar = 16777252
	public var ic_public_calendar_filled = 16777253
	public var ic_public_contacts = 16777254
	public var ic_public_contacts_filled = 16777255
	public var ic_public_download = 16777256
	public var ic_public_folder = 16777257
	public var ic_public_folder_filled = 16777258
	public var ic_public_home = 16777259
	public var ic_public_home_filled = 16777260
	public var layered_image = 16777261
	public var service_financial_integrated_service_system = 16777273
	public var service_financial_paperless_reimbursement = 16777274
	public var service_foreign_affairs = 16777275
	public var service_school_platform = 16777276
	public var service_software_resource_center = 16777277
	public var service_talent_xuegong = 16777278
	public var service_xiaoya = 16777279
	public var service_zhiboketang = 16777280
	public var startIcon = 16777262
	public var startIcon_whut = 16777263
	public var startIcon_whut_f = 16777268
	public var startIcon_whut_fr = 16777269
}

public class AppProfile {
	public var backup_config = 16777264
	public var main_pages = 16777265
	public var route_map = 16777270
}

public class app {
	public static let string = AppString()
	public static let color = AppColor()
	public static let float = AppFloat()
	public static let media = AppMedia()
	public static let profile = AppProfile()
}

public func updateAllRes() {
	let resourceMap: HashMap<String, Int64> = HashMap<String, Int64>()
	resourceMap.put("string EntryAbility_desc", 16777218)
	resourceMap.put("string EntryAbility_label", 16777219)
	resourceMap.put("string app_name", 16777216)
	resourceMap.put("string bottom_text_course", 16777220)
	resourceMap.put("string bottom_text_home", 16777221)
	resourceMap.put("string bottom_text_service", 16777222)
	resourceMap.put("string bottom_text_tools", 16777223)
	resourceMap.put("string bottom_text_user", 16777224)
	resourceMap.put("string module_desc", 16777225)
	resourceMap.put("string page_show", 16777266)
	resourceMap.put("string text_course_table", 16777226)
	resourceMap.put("string text_home", 16777227)
	resourceMap.put("string text_service", 16777228)
	resourceMap.put("string text_tools", 16777229)
	resourceMap.put("string text_user_setting", 16777271)
	resourceMap.put("string tool_electric_charge", 16777230)
	resourceMap.put("color bottom_tab_background_color", 16777231)
	resourceMap.put("color bottom_text_color_normal", 16777232)
	resourceMap.put("color bottom_text_color_selected", 16777233)
	resourceMap.put("color normal_background_grey", 16777234)
	resourceMap.put("color service_block_background", 16777235)
	resourceMap.put("color service_list_background", 16777281)
	resourceMap.put("color start_window_background", 16777236)
	resourceMap.put("color swiper_dot_color", 16777237)
	resourceMap.put("color swiper_dot_color_selected", 16777238)
	resourceMap.put("color whut_blue", 16777248)
	resourceMap.put("color whut_yellow", 16777272)
	resourceMap.put("float border_radius", 16777239)
	resourceMap.put("float bottom_font_size", 16777240)
	resourceMap.put("float component_title_size", 16777241)
	resourceMap.put("float component_title_weight", 16777242)
	resourceMap.put("media app_icon", 16777217)
	resourceMap.put("media background", 16777243)
	resourceMap.put("media banner_campus_map", 16777244)
	resourceMap.put("media banner_full_text_search", 16777245)
	resourceMap.put("media banner_info_gate", 16777246)
	resourceMap.put("media foreground", 16777247)
	resourceMap.put("media ic_arrow_back", 16777267)
	resourceMap.put("media ic_arrow_right_up_and_square", 16777249)
	resourceMap.put("media ic_public_app", 16777250)
	resourceMap.put("media ic_public_app_filled", 16777251)
	resourceMap.put("media ic_public_calendar", 16777252)
	resourceMap.put("media ic_public_calendar_filled", 16777253)
	resourceMap.put("media ic_public_contacts", 16777254)
	resourceMap.put("media ic_public_contacts_filled", 16777255)
	resourceMap.put("media ic_public_download", 16777256)
	resourceMap.put("media ic_public_folder", 16777257)
	resourceMap.put("media ic_public_folder_filled", 16777258)
	resourceMap.put("media ic_public_home", 16777259)
	resourceMap.put("media ic_public_home_filled", 16777260)
	resourceMap.put("media layered_image", 16777261)
	resourceMap.put("media service_financial_integrated_service_system", 16777273)
	resourceMap.put("media service_financial_paperless_reimbursement", 16777274)
	resourceMap.put("media service_foreign_affairs", 16777275)
	resourceMap.put("media service_school_platform", 16777276)
	resourceMap.put("media service_software_resource_center", 16777277)
	resourceMap.put("media service_talent_xuegong", 16777278)
	resourceMap.put("media service_xiaoya", 16777279)
	resourceMap.put("media service_zhiboketang", 16777280)
	resourceMap.put("media startIcon", 16777262)
	resourceMap.put("media startIcon_whut", 16777263)
	resourceMap.put("media startIcon_whut_f", 16777268)
	resourceMap.put("media startIcon_whut_fr", 16777269)
	resourceMap.put("profile backup_config", 16777264)
	resourceMap.put("profile main_pages", 16777265)
	resourceMap.put("profile route_map", 16777270)
}

let updateRes = updateAllRes()

