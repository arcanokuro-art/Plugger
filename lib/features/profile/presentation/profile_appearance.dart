part of '../profile_page.dart';

extension _ProfileAppearance on _ProfilePageState {
  void _appearance() {
    _openPage(
      'Apariencia del perfil',
      (context, data) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Tema del perfil'),
                Tab(text: 'Vista previa'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Estos ajustes se aplican en este dispositivo.',
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 94,
                            ),
                        itemCount: _themes.length,
                        itemBuilder: (_, index) =>
                            _themeTile(context, data, index),
                      ),
                      const SizedBox(height: 16),
                      _panel(context, data, [
                        SwitchListTile(
                          title: const Text('Usar color de acento'),
                          value: data.useAccent,
                          onChanged: (value) => _update('accent', value),
                        ),
                        SwitchListTile(
                          title: const Text('Efecto en portada'),
                          value: data.coverEffect,
                          onChanged: (value) => _update('effect', value),
                        ),
                        SwitchListTile(
                          title: const Text('Bordes redondeados'),
                          value: data.rounded,
                          onChanged: (value) => _update('rounded', value),
                        ),
                      ]),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _header(context, data),
                      _identity(context, data),
                      const SizedBox(height: 16),
                      _post(context, data),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeTile(BuildContext context, ProfileData data, int index) {
    final (name, background, color) = _themes[index];
    final selected = data.theme == index;
    return InkWell(
      onTap: () => _update('theme', index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.alphaBlend(color.withValues(alpha: .36), background),
                    background,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color : color.withValues(alpha: .35),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  selected ? Icons.check_circle : Icons.view_agenda_outlined,
                  size: 21,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, child: Text(name)),
        ],
      ),
    );
  }
}
