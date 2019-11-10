import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/redux/static/static_selectors.dart';
import 'package:invoiceninja_flutter/ui/app/entity_dropdown.dart';
import 'package:invoiceninja_flutter/ui/app/form_card.dart';
import 'package:invoiceninja_flutter/ui/app/forms/app_dropdown_button.dart';
import 'package:invoiceninja_flutter/ui/app/forms/app_form.dart';
import 'package:invoiceninja_flutter/ui/app/forms/bool_dropdown_button.dart';
import 'package:invoiceninja_flutter/ui/app/forms/color_picker.dart';
import 'package:invoiceninja_flutter/ui/settings/invoice_design_vm.dart';
import 'package:invoiceninja_flutter/ui/settings/settings_scaffold.dart';
import 'package:invoiceninja_flutter/utils/fonts.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class InvoiceDesign extends StatefulWidget {
  const InvoiceDesign({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final InvoiceDesignVM viewModel;

  @override
  _InvoiceDesignState createState() => _InvoiceDesignState();
}

class _InvoiceDesignState extends State<InvoiceDesign>
    with SingleTickerProviderStateMixin {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TabController _controller;
  FocusScopeNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusScopeNode();
    _controller = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final viewModel = widget.viewModel;
    final state = viewModel.state;
    final settings = viewModel.settings;
    final company = viewModel.company;
    final designs = company.getInvoiceDesigns();

    return SettingsScaffold(
      title: localization.invoiceDesign,
      onSavePressed: viewModel.onSavePressed,
      appBarBottom: TabBar(
        key: ValueKey(state.settingsUIState.updatedAt),
        controller: _controller,
        tabs: [
          Tab(
            text: localization.generalSettings,
          ),
          Tab(
            text: localization.invoiceOptions,
          ),
        ],
      ),
      body: AppTabForm(
        tabController: _controller,
        formKey: _formKey,
        focusNode: _focusNode,
        children: <Widget>[
          ListView(children: <Widget>[
            FormCard(
              children: <Widget>[
                AppDropdownButton(
                  labelText: localization.invoiceDesign,
                  value: settings.defaultInvoiceDesignId,
                  onChanged: (value) => viewModel.onSettingsChanged(settings
                      .rebuild((b) => b..defaultInvoiceDesignId = value)),
                  items: designs
                      .map((designId) => DropdownMenuItem<String>(
                            value: designId,
                            child: Text(kInvoiceDesigns[designId]),
                          ))
                      .toList(),
                ),
                AppDropdownButton(
                  labelText: localization.quoteDesign,
                  value: settings.defaultQuoteDesignId,
                  onChanged: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..defaultQuoteDesignId = value)),
                  items: designs
                      .map((designId) => DropdownMenuItem<String>(
                            value: designId,
                            child: Text(kInvoiceDesigns[designId]),
                          ))
                      .toList(),
                ),
                AppDropdownButton(
                  labelText: localization.pageSize,
                  value: settings.pageSize,
                  onChanged: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..pageSize = value)),
                  items: kPageSizes
                      .map((pageSize) => DropdownMenuItem<String>(
                            value: pageSize,
                            child: Text(pageSize),
                          ))
                      .toList(),
                ),
                AppDropdownButton(
                  labelText: localization.fontSize,
                  value:
                      settings.fontSize == null ? '' : '${settings.fontSize}',
                  // TODO remove this and 0 from options
                  showBlank: true,
                  onChanged: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..fontSize = int.parse(value))),
                  items: [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
                      .map((fontSize) => DropdownMenuItem<String>(
                            value: '$fontSize',
                            child:
                                fontSize == 0 ? SizedBox() : Text('$fontSize'),
                          ))
                      .toList(),
                ),
              ],
            ),
            FormCard(
              children: <Widget>[
                EntityDropdown(
                  key: ValueKey('__primary_font_${settings.primaryFont}__'),
                  entityType: EntityType.font,
                  labelText: localization.primaryFont,
                  entityId: settings.primaryFont,
                  entityMap: memoizedFontMap(kGoogleFonts),
                  onSelected: (font) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..primaryFont = font?.id)),
                  allowClearing: state.settingsUIState.isFiltered,
                ),
                EntityDropdown(
                  key: ValueKey('__secondary_font_${settings.secondaryFont}__'),
                  entityType: EntityType.font,
                  labelText: localization.secondaryFont,
                  entityId: settings.secondaryFont,
                  entityMap: memoizedFontMap(kGoogleFonts),
                  onSelected: (font) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..secondaryFont = font?.id)),
                  allowClearing: state.settingsUIState.isFiltered,
                ),
                FormColorPicker(
                  labelText: localization.primaryColor,
                  onSelected: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..primaryColor = value)),
                  initialValue: settings.primaryColor,
                ),
                FormColorPicker(
                  labelText: localization.secondaryColor,
                  onSelected: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..secondaryColor = value)),
                  initialValue: settings.secondaryColor,
                ),
              ],
            ),
          ]),
          ListView(
            padding: const EdgeInsets.all(10),
            children: <Widget>[
              FormCard(
                children: <Widget>[
                  BoolDropdownButton(
                    label: localization.allPagesHeader,
                    value: settings.allPagesHeader,
                    iconData: FontAwesomeIcons.fileInvoice,
                    onChanged: (value) => viewModel.onSettingsChanged(
                        settings.rebuild((b) => b..allPagesHeader = value)),
                    enabledLabel: localization.allPages,
                    disabledLabel: localization.firstPage,
                  ),
                  BoolDropdownButton(
                    label: localization.allPagesFooter,
                    value: settings.allPagesFooter,
                    iconData: FontAwesomeIcons.fileInvoice,
                    onChanged: (value) => viewModel.onSettingsChanged(
                        settings.rebuild((b) => b..allPagesFooter = value)),
                    enabledLabel: localization.allPages,
                    disabledLabel: localization.lastPage,
                  ),
                ],
              ),
              FormCard(
                children: <Widget>[
                  BoolDropdownButton(
                    label: localization.hidePaidToDate,
                    helpLabel: localization.hidePaidToDateHelp,
                    value: settings.hidePaidToDate,
                    iconData: FontAwesomeIcons.fileInvoiceDollar,
                    onChanged: (value) => viewModel.onSettingsChanged(
                        settings.rebuild((b) => b..hidePaidToDate = value)),
                  ),
                  BoolDropdownButton(
                    label: localization.invoiceEmbedDocuments,
                    helpLabel: localization.invoiceEmbedDocumentsHelp,
                    value: settings.embedDocuments,
                    iconData: FontAwesomeIcons.image,
                    onChanged: (value) => viewModel.onSettingsChanged(
                        settings.rebuild((b) => b..embedDocuments = value)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}