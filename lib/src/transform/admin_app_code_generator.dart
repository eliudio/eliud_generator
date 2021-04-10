import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

String _imports(String packageName, List<String> depends) => """

import 'package:eliud_core/tools/admin_app_base.dart';
import '../tools/bespoke_models.dart';
import 'package:eliud_core/tools/common_tools.dart';
import 'package:eliud_core/tools/common_tools.dart';

import 'package:eliud_core/model/menu_def_model.dart';
import 'package:eliud_core/model/page_model.dart';
import 'package:eliud_core/model/app_bar_model.dart';
import 'package:eliud_core/model/body_component_model.dart';
import 'package:eliud_core/model/drawer_model.dart';
import 'package:eliud_core/model/menu_item_model.dart';
import 'package:eliud_core/model/home_menu_model.dart';

""" + base_imports(packageName, repo: true, model: true, entity: true, depends: depends);

const String _header = """
class AdminApp extends AdminAppInstallerBase {
  final String appId;
  final DrawerModel _drawer;
  final DrawerModel _endDrawer;
  final AppBarModel _appBar;
  final HomeMenuModel _homeMenu;
  final RgbModel menuItemColor;
  final RgbModel selectedMenuItemColor;
  final RgbModel backgroundColor;
  
  AdminApp(this.appId, this._drawer, this._endDrawer, this._appBar, this._homeMenu, this.menuItemColor, this.selectedMenuItemColor, this.backgroundColor);

""";

// Admin menu
const String _headerAdminMenuDef = """
class AdminMenu extends AdminAppMenuInstallerBase {

  Future<MenuDefModel> menu(String appId) async {
    var menuItems = <MenuItemModel>[];
""";

const String _menuItemDef = """
    menuItems.add(
      MenuItemModel(
        documentID: "\${id}s",
        text: "\${id}s",
        description: "\${id}s",
        icon: IconModel(codePoint: 0xe88a, fontFamily: "MaterialIcons"),
        action: GotoPage(appId, pageID: "\${pkgName}_\${lowid}s_page"))
    );

""";

const String _footerAdminMenuDef = """
    MenuDefModel menu = MenuDefModel(
      admin: true,
      documentID: "\${pkgName}_admin_menu",
      appId: appId,
      name: "\${pkgName}",
      menuItems: menuItems
    );
    await menuDefRepository(appId: appId)!.add(menu);
    return menu;
  }
}
""";


// Page
const String _page = """
  PageModel _\${lid}sPages() {
    List<BodyComponentModel> components = [];
    components.add(BodyComponentModel(
      documentID: "internalWidget-\${lid}s", componentName: "\${pkgName}_internalWidgets", componentId: "\${lid}s"));
    PageModel page = PageModel(
        conditions: ConditionsModel(
          privilegeLevelRequired: PrivilegeLevelRequired.OwnerPrivilegeRequired,
          packageCondition: null,
          conditionOverride: null,
        ),
        appId: appId,
        documentID: "\${pkgName}_\${lowid}s_page",
        title: "\${id}s",
        drawer: _drawer,
        endDrawer: _endDrawer,
        appBar: _appBar,
        homeMenu: _homeMenu,
        bodyComponents: components,
        layout: PageLayout.OnlyTheFirstComponent
    );
    return page;
  }

""";

// _setupAdminPages
const String _setupAdminPagesHeader = """
  Future<void> _setupAdminPages() {
""";

const String _setupAdminPagesFirstPage = """
    return pageRepository(appId: appId)!.add(_\${lid}sPages())
""";

const String _setupAdminPagesOtherPages = """
        .then((_) => pageRepository(appId: appId)!.add(_\${lid}sPages()))
""";

const String _setupAdminPagesFooter = """
    ;
  }

  @override
  Future<void> run() async {
    return _setupAdminPages();
  }

""";

// run
const String _headerRun = """
class AdminAppWiper extends AdminAppWiperBase {

  @override
  Future<void> deleteAll(String appId) async {
""";

const String _footerOther = """
    await \${lid}Repository(appId: appId)!.deleteAll();
""";

const String _footerOtherNoApp = """
    await \${lid}Repository()!.deleteAll();
""";

const String _footerApp = """
""";

const String _footerRun = """
    ;
  }

""";

// footer
const String _footer = """
}
""";

class AdminAppCodeGenerator extends CodeGeneratorMulti {
  AdminAppCodeGenerator(String fileName) : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    var pkgName = sharedPackageName(modelSpecificationPlus);
    codeBuffer.write(header());
    codeBuffer.writeln(process(_imports(sharedPackageName(modelSpecificationPlus), mergeAllDepends(modelSpecificationPlus))));
    codeBuffer.writeln(process(_header));

    // Pages
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        codeBuffer.writeln(process(_page, parameters: <String, String>{
          '\${id}': spec.modelSpecification.id,
          '\${lid}': firstLowerCase(spec.modelSpecification.id),
          '\${lowid}': allLowerCase(spec.modelSpecification.id),
          '\${pkgName}': pkgName,
        }));
      }
    });

    // _setupAdminPages
    codeBuffer.writeln(process(_setupAdminPagesHeader));
    bool first = true;
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        if (first)
          codeBuffer.writeln(process(_setupAdminPagesFirstPage, parameters: <String, String>{
            '\${id}': spec.modelSpecification.id,
            '\${lid}': firstLowerCase(spec.modelSpecification.id),
            '\${lowid}': allLowerCase(spec.modelSpecification.id)
          }));
        else
          codeBuffer.writeln(process(_setupAdminPagesOtherPages, parameters: <String, String>{
            '\${id}': spec.modelSpecification.id,
            '\${lid}': firstLowerCase(spec.modelSpecification.id),
            '\${lowid}': allLowerCase(spec.modelSpecification.id)
          }));
        first = false;
      }
    });
    codeBuffer.writeln(process(_setupAdminPagesFooter));

    codeBuffer.writeln(process(_footer));




    // MenuDef
    codeBuffer.writeln(process(_headerAdminMenuDef));
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        codeBuffer.writeln(process(_menuItemDef, parameters: <String, String>{
          '\${id}': spec.modelSpecification.id,
          '\${lowid}': allLowerCase(spec.modelSpecification.id),
          '\${pkgName}': pkgName,
        }));
      }
    });
    codeBuffer.writeln(process(_footerAdminMenuDef, parameters: <String, String>{
      '\${pkgName}': pkgName,
    }));




    codeBuffer.write(process(_headerRun));

    modelSpecificationPlus.forEach((spec) {
      if (spec.modelSpecification.generate.hasPersistentRepository) {
        Map<String, String> parameters = <String, String>{ '\${lid}': firstLowerCase(spec.modelSpecification.id) };
        if ((spec.modelSpecification.id != "Member") && (spec.modelSpecification.id != "App") && (!spec.modelSpecification.generate.isDocumentCollection)) {
          if (spec.modelSpecification.isAppModel) {
            codeBuffer.write(process(_footerOther, parameters: parameters));
          } else {
            codeBuffer.write(process(_footerOtherNoApp, parameters: parameters));
          }
        }
      }
    });
    Map<String, String> parameters = <String, String>{ '\${lid}': 'app' };
    codeBuffer.write(process(_footerApp, parameters: parameters));
    codeBuffer.writeln(process(_footerRun));

    codeBuffer.writeln(process(_footer));

    return codeBuffer.toString();
  }
}
