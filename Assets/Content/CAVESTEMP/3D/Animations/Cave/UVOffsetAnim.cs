using UnityEngine;
using System.Collections;

public sealed class UVOffsetAnim : MonoBehaviour 
{
	[SerializeField]
	private Renderer _Renderer;

	[SerializeField]
	private string _NameOfTexture;

	[SerializeField]
	private Vector2 _Speed = new Vector2(1.0f, 1.0f);

	void Awake()
	{
		//Force singleton-like behaviour
		//We destroy every UVA that affects the same material and texture so we don't get additive animation
		//for each one in the scene.
		foreach(UVOffsetAnim uva in GameObject.FindObjectsOfType<UVOffsetAnim>())
		{
			if (uva == this)
				continue;

			if (uva._Renderer.sharedMaterial == this._Renderer.sharedMaterial && uva._NameOfTexture == this._NameOfTexture)
			{
#if UNITY_EDITOR
				Debug.Log("Destroying a UVAnimator.");
#endif
				DestroyImmediate(uva);
			}
		}
	}

	private void FixedUpdate()
	{
		Vector2 currentOffset = _Renderer.sharedMaterial.GetTextureOffset(_NameOfTexture);

		currentOffset.x = Mathf.Abs(currentOffset.x) == 1 ? 0 : currentOffset.x;
		currentOffset.y = Mathf.Abs(currentOffset.y) == 1 ? 0 : currentOffset.y;

		currentOffset.x = Mathf.Clamp(currentOffset.x + (Time.deltaTime * _Speed.x), -1, 1);
		currentOffset.y = Mathf.Clamp(currentOffset.y + (Time.deltaTime * _Speed.y), -1, 1);

		_Renderer.sharedMaterial.SetTextureOffset(_NameOfTexture, currentOffset);
	}
}
