# Controlador base para todos los controladores que responden a clientes web.
require 'csv'
require 'application_responder'

class ApplicationController < ActionController::Base
  include BrowserDetect, ApplicationHelper

  # Responders
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery

  # Antes que nada configurar el locale
  before_action :configurar_locale_para_request
  before_filter :descubrir_browser
  before_filter :agregar_parametros_permitidos, if: :devise_controller?

  # CanCan necesita un método *current_user* y Devise genera la función
  # en base al nombre del modelo, que en nuestro caso es Usuario
  def current_user
    self.current_usuario
  end

  def current_usuario
    super.try(:decorate)
  end

  def configurar_locale_para_request
    I18n.locale = elegir_locale(params[:locale])
  end

  # Define qué locale se va a usar en base al parámetro enviado si es uno de
  # los locales soportados. En caso contrario, usar el preferido del usuario,
  # si tiene.
  def elegir_locale(locale)
    locale_sanitizado = I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil

    locale_sanitizado || current_usuario.try(:idioma) || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  # Completa variables de instancia para usar en las vistas con información sobre el navegador de la
  # solicitud.
  def descubrir_browser
    @ie = browser_is?('ie')
    @mobile = browser_is_mobile?
  end

  # Métodos de BrowserDetect
  helper_method :browser_is?, :browser_webkit_version, :ua, :browser_is_mobile?

  # Ayuda para todos
  helper_method :ayuda_para

  # Para ordenar las columnas
  helper_method :direccion_de_ordenamiento, :metodo_de_ordenamiento

  protected

    def agregar_parametros_permitidos
      devise_parameter_sanitizer.permit :account_update, keys: [:nombre]
      devise_parameter_sanitizer.permit :sign_up, keys: [:nombre, :idioma]
    end

    def direccion_de_ordenamiento
      %w[asc desc].include?(params[:direccion]) ? params[:direccion] : 'asc'
    end

    # Para los mensajes del flash de responders
    def interpolation_options
      { el_la: 'el' }
    end

    # La ficha o plantilla de carga que seleccionó el usuario en la acción
    # anterior. Si no hay, se usa la que definió en su perfil de usuario. Si no
    # hay usuario, usamos la default
    def seleccionar_ficha
      @ficha = begin
        Ficha.find session[:ficha]
      rescue ActiveRecord::RecordNotFound
        current_usuario.try(:ficha) || Ficha.default
      end
    end
end
