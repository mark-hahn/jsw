jsw = require '../lib/jsw'

describe "jsw", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('my-package')

  describe "when the my-package:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.my-package')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'my-package:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.my-package')).toExist()

        myPackageElement = workspaceElement.querySelector('.my-package')
        expect(myPackageElement).toExist()

        myPackagePanel = atom.workspace.panelForItem(myPackageElement)
        expect(myPackagePanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'my-package:toggle'
        expect(myPackagePanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.my-package')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'my-package:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        myPackageElement = workspaceElement.querySelector('.my-package')
        expect(myPackageElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'my-package:toggle'
        expect(myPackageElement).not.toBeVisible()
