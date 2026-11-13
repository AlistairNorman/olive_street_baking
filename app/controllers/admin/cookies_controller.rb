module Admin
  class CookiesController < ::SolidusAdmin::ResourcesController
    private

    def resource_class = Cookie

    def authorization_subject = Cookie

    def permitted_resource_params
      params.require(:cookie).permit(:name, :ingredients)
    end
  end
end
